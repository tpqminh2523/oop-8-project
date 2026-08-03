#include "category_dao.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QUrl>

CategoryDAO::CategoryDAO() {
    loadFromCSV();
}

int CategoryDAO::generateNextId() const {
    int maxId = 0;
    for (const Category& cat : m_categories) {
        if (cat.getId() > maxId) {
            maxId = cat.getId();
        }
    }
    return maxId + 1;
}

const QVector<Category>& CategoryDAO::getAll() const {
    return m_categories;
}

void CategoryDAO::add(const Category& item) {
    Category newItem = item;
    if (newItem.getId() <= 0) {
        newItem.setId(generateNextId());
    }
    m_categories.append(newItem);
    saveToCSV();
}

bool CategoryDAO::update(int id, const Category& item) {
    for (Category& cat : m_categories) {
        if (cat.getId() == id) {
            cat = item;
            cat.setId(id); // Ensure ID doesn't change
            saveToCSV();
            return true;
        }
    }
    return false;
}

bool CategoryDAO::remove(int id) {
    for (int i = 0; i < m_categories.size(); ++i) {
        if (m_categories[i].getId() == id) {
            m_categories.removeAt(i);
            saveToCSV();
            return true;
        }
    }
    return false;
}

void CategoryDAO::loadFromCSV() {
    m_categories.clear();
    QFile file("categories.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open categories.csv. Starting with empty list.";
        return;
    }

    QTextStream in(&file);
    if (!in.atEnd()) {
        in.readLine();
    }

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 3) {
            int id = fields[0].toInt();
            QString name = fields[1];
            int parentId = fields[2].toInt();
            
            bool active = true;
            if (fields.size() >= 4) {
                active = fields[3].toInt() != 0;
            }

            Category cat(id, parentId, name);
            cat.setActive(active);
            m_categories.append(cat);
        }
    }
    file.close();
}

void CategoryDAO::saveToCSV() const {
    QFile file("categories.csv");
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return;
    }

    QTextStream out(&file);
    out << "id,name,parentId,active\n";
    for (const Category& cat : m_categories) {
        out << cat.getId() << ","
            << cat.getName() << ","
            << cat.getParentId() << ","
            << (cat.isActive() ? 1 : 0) << "\n";
    }
    file.close();
}

void CategoryDAO::updateParent(int id, int newParentId) {
    for (Category& cat : m_categories) {
        if (cat.getId() == id) {
            cat.setParentId(newParentId);
            saveToCSV();
            break;
        }
    }
}

void CategoryDAO::migrateAndRemove(int sourceCatId, int targetCatId) {
    // Migration logic typically involves updating transactions, which belongs to TransactionDAO.
    // So this might just remove it, or we leave the cross-dao logic to DatabaseManager.
    remove(sourceCatId);
}

void CategoryDAO::deactivate(int id) {
    for (Category& cat : m_categories) {
        if (cat.getId() == id) {
            cat.setActive(false);
            saveToCSV();
            break;
        }
    }
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

bool CategoryDAO::exportToCSV(const QString& targetFilePath) const {
    QString cleanPath = resolveLocalPath(targetFilePath);
    QFile file(cleanPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    QTextStream out(&file);
    out << "id,name,parentId\n";
    for (const Category& cat : m_categories) {
        out << cat.getId() << ","
            << cat.getName() << ","
            << cat.getParentId() << "\n";
    }
    file.close();
    return true;
}
