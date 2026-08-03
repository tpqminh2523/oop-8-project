#include "bill_dao.h"

BillDAO::BillDAO() {
    loadFromCSV();
}

const QVector<Bill>& BillDAO::getAll() const {
    return m_bills;
}

void BillDAO::add(const Bill& item) {
    m_bills.append(item);
    saveToCSV();
}

bool BillDAO::update(int id, const Bill& item) {
    for (int i = 0; i < m_bills.size(); ++i) {
        if (m_bills[i].getId() == id) {
            m_bills[i] = item;
            saveToCSV();
            return true;
        }
    }
    return false;
}

bool BillDAO::remove(int id) {
    for (int i = 0; i < m_bills.size(); ++i) {
        if (m_bills[i].getId() == id) {
            m_bills.removeAt(i);
            saveToCSV();
            return true;
        }
    }
    return false;
}

void BillDAO::loadFromCSV() {
    // TODO: Implement loading bills from CSV
}

void BillDAO::saveToCSV() const {
    // TODO: Implement saving bills to CSV
}

bool BillDAO::exportToCSV(const QString& targetFilePath) const {
    // TODO: Implement exporting bills to CSV
    return false;
}
