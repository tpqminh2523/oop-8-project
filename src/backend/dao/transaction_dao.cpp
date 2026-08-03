#include "transaction_dao.h"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QDebug>
#include <QStandardPaths>
#include <QUrl>

TransactionDAO::TransactionDAO() {
    loadFromCSV();
}

TransactionDAO::~TransactionDAO() {
    qDeleteAll(m_transactions);
    m_transactions.clear();
}

int TransactionDAO::generateNextId() const {
    int maxId = 0;
    for (Transaction* tx : m_transactions) {
        if (tx->getId() > maxId) {
            maxId = tx->getId();
        }
    }
    return maxId + 1;
}

const QVector<Transaction*>& TransactionDAO::getAll() const {
    return m_transactions;
}

void TransactionDAO::add(Transaction* item) {
    if (item) {
        if (item->getId() <= 0) {
            item->setId(generateNextId());
        }
        m_transactions.append(item);
        saveToCSV();
    }
}

bool TransactionDAO::update(int id, Transaction* item) {
    for (int i = 0; i < m_transactions.size(); ++i) {
        if (m_transactions[i]->getId() == id) {
            delete m_transactions[i];
            item->setId(id);
            m_transactions[i] = item;
            saveToCSV();
            return true;
        }
    }
    return false;
}

bool TransactionDAO::remove(int id) {
    for (int i = 0; i < m_transactions.size(); ++i) {
        if (m_transactions[i]->getId() == id) {
            delete m_transactions[i];
            m_transactions.removeAt(i);
            saveToCSV();
            return true;
        }
    }
    return false;
}

void TransactionDAO::loadFromCSV() {
    qDeleteAll(m_transactions);
    m_transactions.clear();

    QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(appDataDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    
    QString filePath = dir.filePath("transactions.csv");
    QFile file(filePath);
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return;
    }

    QTextStream in(&file);
    if (!in.atEnd()) {
        in.readLine();
    }

    while (!in.atEnd()) {
        QString line = in.readLine();
        QStringList fields = line.split(",");
        
        if (fields.size() >= 13) {
            int id = fields[0].toInt();
            double amount = fields[1].toDouble();
            QDateTime dateTime = QDateTime::fromString(fields[2], Qt::ISODate);
            QString note = fields[3];
            int categoryId = fields[4].toInt();
            QString txType = fields[5];
            QString payMethod = fields[6];
            QString classType = fields[7];
            QString receipt = fields[8];
            QString status = fields[9];
            QString payer = fields[10];
            QString payee = fields[11];
            bool isEssential = (fields[12] == "1" || fields[12].toLower() == "true");

            Transaction* newTx = nullptr;
            if (classType == "Income") {
                newTx = new Income(id, amount, dateTime, note, categoryId, txType, payMethod, receipt, status, payer);
            } else if (classType == "Expense") {
                newTx = new Expense(id, amount, dateTime, note, categoryId, txType, payMethod, receipt, status, payee, isEssential);
            } else {
                newTx = new Transaction(id, amount, dateTime, note, categoryId, txType, payMethod, receipt, status);
            }
            
            if (newTx) {
                m_transactions.append(newTx);
            }
        }
    }
    file.close();
}

void TransactionDAO::saveToCSV() const {
    QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(appDataDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    
    QString filePath = dir.filePath("transactions.csv");
    QFile file(filePath);
    
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return;
    }

    QTextStream out(&file);
    out << "ID,Amount,DateTime,Note,CategoryId,TransactionType,PaymentMethod,ClassType,ReceiptImagePath,Status,Payer,Payee,IsEssential\n";

    for (Transaction* tx : m_transactions) {
        QString classType = "Transaction";
        QString payer = "";
        QString payee = "";
        QString isEssential = "";

        if (Income* income = dynamic_cast<Income*>(tx)) {
            classType = "Income";
            payer = income->getPayer();
        } else if (Expense* expense = dynamic_cast<Expense*>(tx)) {
            classType = "Expense";
            payee = expense->getPayee();
            isEssential = expense->getIsEssential() ? "1" : "0";
        }

        out << tx->getId() << ","
            << QString::number(tx->getAmount(), 'f', 2) << ","
            << tx->getDateTime().toString(Qt::ISODate) << ","
            << tx->getNote() << ","
            << tx->getCategoryId() << ","
            << tx->getTransactionType() << ","
            << tx->getPaymentMethod() << ","
            << classType << ","
            << tx->getReceiptImagePath() << ","
            << tx->getStatus() << ","
            << payer << ","
            << payee << ","
            << isEssential << "\n";
    }
    
    file.close();
}

static QString resolveLocalPath(const QString& path) {
    QUrl url(path);
    if (url.isValid() && url.isLocalFile()) {
        return url.toLocalFile();
    }
    if (path.startsWith("file:", Qt::CaseInsensitive)) {
        return QUrl(path).toLocalFile();
    }
    return path;
}

bool TransactionDAO::exportToCSV(const QString& targetFilePath) const {
    QString cleanPath = resolveLocalPath(targetFilePath);
    QFile file(cleanPath);
    
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    QTextStream out(&file);
    out << "ID,Amount,DateTime,Note,CategoryId,TransactionType,PaymentMethod,ClassType,ReceiptImagePath,Status,Payer,Payee,IsEssential\n";

    for (Transaction* tx : m_transactions) {
        QString classType = "Transaction";
        QString payer = "";
        QString payee = "";
        QString isEssential = "";

        if (Income* income = dynamic_cast<Income*>(tx)) {
            classType = "Income";
            payer = income->getPayer();
        } else if (Expense* expense = dynamic_cast<Expense*>(tx)) {
            classType = "Expense";
            payee = expense->getPayee();
            isEssential = expense->getIsEssential() ? "1" : "0";
        }

        out << tx->getId() << ","
            << QString::number(tx->getAmount(), 'f', 2) << ","
            << tx->getDateTime().toString(Qt::ISODate) << ","
            << tx->getNote() << ","
            << tx->getCategoryId() << ","
            << tx->getTransactionType() << ","
            << tx->getPaymentMethod() << ","
            << classType << ","
            << tx->getReceiptImagePath() << ","
            << tx->getStatus() << ","
            << payer << ","
            << payee << ","
            << isEssential << "\n";
    }
    
    file.close();
    return true;
}
