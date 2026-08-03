#ifndef IBASE_DAO_H
#define IBASE_DAO_H

#include <QVector>

template <typename T>
class IBaseDAO {
public:
    virtual ~IBaseDAO() = default;

    // Lấy toàn bộ danh sách
    virtual const QVector<T>& getAll() const = 0;

    // Thêm mới
    virtual void add(const T& item) = 0;

    // Cập nhật
    virtual bool update(int id, const T& item) = 0;

    // Xóa
    virtual bool remove(int id) = 0;
};

// Partial specialization for pointer types like Transaction*
template <typename T>
class IBaseDAO<T*> {
public:
    virtual ~IBaseDAO() = default;

    // Lấy toàn bộ danh sách
    virtual const QVector<T*>& getAll() const = 0;

    // Thêm mới
    virtual void add(T* item) = 0;

    // Cập nhật
    virtual bool update(int id, T* item) = 0;

    // Xóa
    virtual bool remove(int id) = 0;
};

#endif // IBASE_DAO_H
