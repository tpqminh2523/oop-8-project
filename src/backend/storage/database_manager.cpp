// database_manager.cpp
#include "database_manager.h"
#include <QDir>
#include <QUrl>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {
    m_categoryDAO = new CategoryDAO();
    m_billDAO = new BillDAO();
    m_budgetDAO = new BudgetDAO();
    m_savingDAO = new SavingDAO();
    m_transactionDAO = new TransactionDAO();
}

DatabaseManager::~DatabaseManager() {
    delete m_categoryDAO;
    delete m_billDAO;
    delete m_budgetDAO;
    delete m_savingDAO;
    delete m_transactionDAO;
}

void DatabaseManager::addExpenseToBudget(int categoryId, double amount) {
    // Left unimplemented to match previous behavior, 
    // or can be implemented by coordinating m_budgetDAO
}

bool DatabaseManager::contributeToSaving(int savingId, double amount) {
    // Left unimplemented to match previous behavior
    return false;
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

bool DatabaseManager::exportAllToCSV(const QString& targetFolderPath) const {
    QString cleanDir = resolveLocalPath(targetFolderPath);
    QDir dir(cleanDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    bool success = true;
    success &= m_categoryDAO->exportToCSV(cleanDir + "/categories_export.csv");
    success &= m_transactionDAO->exportToCSV(cleanDir + "/transactions_export.csv");
    success &= m_billDAO->exportToCSV(cleanDir + "/bills_export.csv");
    success &= m_budgetDAO->exportToCSV(cleanDir + "/budgets_export.csv");
    success &= m_savingDAO->exportToCSV(cleanDir + "/savings_export.csv");

    return success;
}
