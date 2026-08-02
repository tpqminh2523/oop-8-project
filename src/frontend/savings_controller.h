#ifndef SAVINGS_CONTROLLER_H
#define SAVINGS_CONTROLLER_H

#include <QAbstractListModel>
#include <QString>
#include <QVector>
#include "../backend/models/saving.h"

class SavingsController : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(double totalSaved READ totalSaved NOTIFY statsChanged)
    Q_PROPERTY(double totalRemaining READ totalRemaining NOTIFY statsChanged)
    Q_PROPERTY(int completedCount READ completedCount NOTIFY statsChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY statsChanged)

    Q_PROPERTY(int priorityFilter READ priorityFilter WRITE setPriorityFilter NOTIFY filterChanged)
    Q_PROPERTY(int categoryIdFilter READ categoryIdFilter WRITE setCategoryIdFilter NOTIFY filterChanged)
    Q_PROPERTY(QString searchKeyword READ searchKeyword WRITE setSearchKeyword NOTIFY filterChanged)

public:
    enum SavingRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        PriorityRole,
        CategoryIdRole,
        CategoryNameRole,
        CurrentRole,
        TargetRole,
        ProgressFractionRole,
        ProgressPercentRole,
        DueDateRole,
        CompletedRole
    };

    explicit SavingsController(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    double totalSaved() const;
    double totalRemaining() const;
    int completedCount() const;
    int totalCount() const;

    int priorityFilter() const;
    void setPriorityFilter(int filter);

    int categoryIdFilter() const;
    void setCategoryIdFilter(int catId);

    QString searchKeyword() const;
    void setSearchKeyword(const QString &keyword);

    Q_INVOKABLE void loadSavings();
    Q_INVOKABLE void addSaving(const QString &name, int priority, int categoryId, double target,
                               double current, const QString &dueDateStr);
    Q_INVOKABLE void updateSaving(int id, const QString &name, int priority, int categoryId, double target,
                                  double current, const QString &dueDateStr);
    Q_INVOKABLE void deleteSaving(int id);
    Q_INVOKABLE void contributeToSaving(int id, double amount);

signals:
    void statsChanged();
    void filterChanged();

private:
    void calculateStats();

    QVector<Saving> m_allSavings;
    QVector<const Saving*> m_filteredSavings;

    double m_totalSaved;
    double m_totalRemaining;
    int m_completedCount;

    int m_priorityFilter;   // -1: All, 0: Low, 1: Medium, 2: High
    int m_categoryIdFilter; // 0: All
    QString m_searchKeyword;
};

#endif // SAVINGS_CONTROLLER_H
