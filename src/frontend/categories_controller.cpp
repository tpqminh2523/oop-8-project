#include "categories_controller.h"
#include <QLocale>

CategoriesController::CategoriesController(QObject *parent)
    : QObject(parent), m_searchText(""), m_parentFilter(0) {}

void CategoriesController::setSearchText(const QString &text) {
    if (m_searchText != text) {
        m_searchText = text;
        emit filterChanged();
        emit categoriesChanged();
    }
}

void CategoriesController::setParentFilter(int filter) {
    if (m_parentFilter != filter) {
        m_parentFilter = filter;
        emit filterChanged();
        emit categoriesChanged();
    }
}

static QString getParentCategoryName(int parentId) {
    switch (parentId) {
        case 1: return "Income";
        case 2: return "Expense";
        case 3: return "Bill";
        case 4: return "Budget";
        case 5: return "Saving";
        default: return "General";
    }
}

QVariantList CategoriesController::categoriesList() const {
    QVariantList list;
    const QVector<Category>& categories = DatabaseManager::instance().getAllCategories();
    const QVector<Transaction*>& transactions = DatabaseManager::instance().getAllTransactions();

    for (const auto &cat : categories) {
        // Filter by parentId (0 means All Categories)
        if (m_parentFilter > 0 && cat.getParentId() != m_parentFilter) {
            continue;
        }

        // Filter by searchText
        if (!m_searchText.isEmpty() && !cat.getName().contains(m_searchText, Qt::CaseInsensitive)) {
            continue;
        }

        // Sum every real transaction that belongs to this category (was hardcoded to "0 VND")
        double totalAmount = 0.0;
        for (const Transaction* t : transactions) {
            if (t && t->getCategoryId() == cat.getId()) {
                totalAmount += t->getAmount();
            }
        }

        QVariantMap item;
        item["id"] = cat.getId();
        item["name"] = cat.getName();
        item["parentId"] = cat.getParentId();
        item["parentName"] = getParentCategoryName(cat.getParentId());
        item["active"] = cat.isActive();
        item["status"] = cat.isActive() ? "Active" : "Inactive";
        item["totalAmount"] = totalAmount;
        item["totalAmountFormatted"] = QLocale::system().toString(totalAmount, 'f', 0) + " VND";

        list.append(item);
    }

    return list;
}

bool CategoriesController::addCategory(const QString &name, int parentId, bool active) {
    if (name.trimmed().isEmpty()) return false;
    DatabaseManager::instance().addUserCustomCategory(name.trimmed(), parentId, active);
    emit categoriesChanged();
    return true;
}

bool CategoriesController::updateCategory(int id, const QString &name, int newParentId, bool active) {
    if (name.trimmed().isEmpty()) return false;
    DatabaseManager::instance().updateCategory(id, name.trimmed(), newParentId, active);
    emit categoriesChanged();
    return true;
}

bool CategoriesController::updateCategoryParent(int id, int newParentId) {
    DatabaseManager::instance().updateCategoryParent(id, newParentId);
    emit categoriesChanged();
    return true;
}

bool CategoriesController::removeCategory(int id) {
    DatabaseManager::instance().removeCategory(id);
    emit categoriesChanged();
    return true;
}

bool CategoriesController::migrateAndRemoveCategory(int sourceId, int targetId) {
    DatabaseManager::instance().migrateAndRemoveCategory(sourceId, targetId);
    emit categoriesChanged();
    return true;
}

bool CategoriesController::deactivateCategory(int id) {
    DatabaseManager::instance().deactivateCategory(id);
    emit categoriesChanged();
    return true;
}

void CategoriesController::refresh() {
    emit categoriesChanged();
}