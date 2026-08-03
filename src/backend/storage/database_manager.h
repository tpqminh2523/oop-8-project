// database_manager.h
#ifndef DATABASE_MANAGER_H
#define DATABASE_MANAGER_H

#include <QObject>
#include <QString>
#include <QCoreApplication>
#include <QDir>
#include "../dao/category_dao.h"
#include "../dao/bill_dao.h"
#include "../dao/budget_dao.h"
#include "../dao/saving_dao.h"
#include "../dao/transaction_dao.h"

class DatabaseManager : public QObject {
    Q_OBJECT

private:
    CategoryDAO* m_categoryDAO;
    BillDAO* m_billDAO;
    BudgetDAO* m_budgetDAO;
    SavingDAO* m_savingDAO;
    TransactionDAO* m_transactionDAO;

    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

public:
    static DatabaseManager& instance() {
        static DatabaseManager instance;
        return instance;
    }

    DatabaseManager(const DatabaseManager&) = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;

    static QString getDataDirectoryPath() {
        static QString cachedPath;
        if (cachedPath.isEmpty()) {
            QDir devDir(QCoreApplication::applicationDirPath() + "/../../data");
            if (devDir.exists()) {
                cachedPath = devDir.absolutePath();
            } else {
                cachedPath = QCoreApplication::applicationDirPath() + "/data";
            }
        }
        return cachedPath;
    }

signals:
    void dataChanged();

public:
    CategoryDAO* categoryDAO() const { return m_categoryDAO; }
    BillDAO* billDAO() const { return m_billDAO; }
    BudgetDAO* budgetDAO() const { return m_budgetDAO; }
    SavingDAO* savingDAO() const { return m_savingDAO; }
    TransactionDAO* transactionDAO() const { return m_transactionDAO; }

    // Cross-cutting business logic
    void addExpenseToBudget(int categoryId, double amount);
    bool contributeToSaving(int savingId, double amount);
    
    // Export All
    bool exportAllToCSV(const QString& targetFolderPath) const;
};

#endif // DATABASE_MANAGER_H