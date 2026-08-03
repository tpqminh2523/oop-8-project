#ifndef CATEGORY_DAO_H
#define CATEGORY_DAO_H

#include "ibase_dao.h"
#include "../models/category.h"

class CategoryDAO : public IBaseDAO<Category> {
private:
    QVector<Category> m_categories;

    int generateNextId() const;
public:
    CategoryDAO();
    ~CategoryDAO() override = default;

    // Implementation of IBaseDAO
    const QVector<Category>& getAll() const override;
    void add(const Category& item) override;
    bool update(int id, const Category& item) override;
    bool remove(int id) override;

    // Category specific methods
    void loadFromCSV();
    void saveToCSV() const;
    
    // Additional domain logic
    void updateParent(int id, int newParentId);
    void migrateAndRemove(int sourceCatId, int targetCatId);
    void deactivate(int id);
    bool exportToCSV(const QString& targetFilePath) const;
};

#endif // CATEGORY_DAO_H
