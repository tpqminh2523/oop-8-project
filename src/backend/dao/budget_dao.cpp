#include "budget_dao.h"

BudgetDAO::BudgetDAO() {
    loadFromCSV();
}

const QVector<Budget>& BudgetDAO::getAll() const {
    return m_budgets;
}

void BudgetDAO::add(const Budget& item) {
    m_budgets.append(item);
    saveToCSV();
}

bool BudgetDAO::update(int id, const Budget& item) {
    for (int i = 0; i < m_budgets.size(); ++i) {
        if (m_budgets[i].getId() == id) {
            m_budgets[i] = item;
            saveToCSV();
            return true;
        }
    }
    return false;
}

bool BudgetDAO::remove(int id) {
    for (int i = 0; i < m_budgets.size(); ++i) {
        if (m_budgets[i].getId() == id) {
            m_budgets.removeAt(i);
            saveToCSV();
            return true;
        }
    }
    return false;
}

void BudgetDAO::loadFromCSV() {
    // TODO: Implement loading budgets from CSV
}

void BudgetDAO::saveToCSV() const {
    // TODO: Implement saving budgets to CSV
}

bool BudgetDAO::exportToCSV(const QString& targetFilePath) const {
    // TODO: Implement exporting budgets to CSV
    return false;
}
