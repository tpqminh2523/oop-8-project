#ifndef CATEGORY_H
#define CATEGORY_H

#include <QString>

class Category {
private:
    int id;
    int parentId;
    QString name;        // Tên danh mục (Ăn uống, Học phí...)
    bool active = true;  // Trạng thái hoạt động
public:
    Category();

    //hàm cho backend
    Category(int n_id, int n_parentid, const QString& n_name);
    //hàm cho frontend
    Category(int n_parentid, const QString& n_name);
    //ngoại trừ hàm getter và setter thì các hàm khác không được viết logic của nó trực tiếp ở đây, đi qua .cpp để viết đi.

    //getter
    int getId() const {return id;}
    int getParentId() const {return parentId;}
    QString getName() const {return name;}
    bool isActive() const {return active;}

    //setter
    void setId(int newId) { id = newId; }
    void setActive(bool isActive) { active = isActive; }
    void setParentId(int newParentId) { parentId = newParentId; }

    static QString parentCategoryName(int parentId);

};

#endif // CATEGORY_H