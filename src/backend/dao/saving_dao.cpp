#include "saving_dao.h"

SavingDAO::SavingDAO() {
    loadFromCSV();
}

const QVector<Saving>& SavingDAO::getAll() const {
    return m_savings;
}

void SavingDAO::add(const Saving& item) {
    m_savings.append(item);
    saveToCSV();
}

bool SavingDAO::update(int id, const Saving& item) {
    for (int i = 0; i < m_savings.size(); ++i) {
        if (m_savings[i].getId() == id) {
            m_savings[i] = item;
            saveToCSV();
            return true;
        }
    }
    return false;
}

bool SavingDAO::remove(int id) {
    for (int i = 0; i < m_savings.size(); ++i) {
        if (m_savings[i].getId() == id) {
            m_savings.removeAt(i);
            saveToCSV();
            return true;
        }
    }
    return false;
}

void SavingDAO::loadFromCSV() {
    // TODO: Implement loading savings from CSV
}

void SavingDAO::saveToCSV() const {
    // TODO: Implement saving savings to CSV
}

bool SavingDAO::exportToCSV(const QString& targetFilePath) const {
    // TODO: Implement exporting savings to CSV
    return false;
}
