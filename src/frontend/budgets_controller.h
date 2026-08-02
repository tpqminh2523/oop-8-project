#ifndef BUDGETS_CONTROLLER_H
#define BUDGETS_CONTROLLER_H

#include <QAbstractListModel>
#include <QString>
#include <QVector>
#include "../backend/models/budget.h"

class BudgetsController : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(double totalSpent READ totalSpent NOTIFY statsChanged)
    Q_PROPERTY(double totalLimit READ totalLimit NOTIFY statsChanged)
    Q_PROPERTY(double totalRemaining READ totalRemaining NOTIFY statsChanged)

    Q_PROPERTY(int priorityFilter READ priorityFilter WRITE setPriorityFilter NOTIFY filterChanged)
    Q_PROPERTY(int categoryIdFilter READ categoryIdFilter WRITE setCategoryIdFilter NOTIFY filterChanged)
    Q_PROPERTY(QString searchKeyword READ searchKeyword WRITE setSearchKeyword NOTIFY filterChanged)

public:
    enum BudgetRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        PriorityRole,
        CategoryIdRole,
        CategoryNameRole,
        SpentRole,
        LimitRole,
        ProgressFractionRole,
        ProgressPercentRole,
        StartDateRole,
        EndDateRole,
        PeriodRole
    };

    explicit BudgetsController(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    double totalSpent() const;
    double totalLimit() const;
    double totalRemaining() const;

    int priorityFilter() const;
    void setPriorityFilter(int filter);

    int categoryIdFilter() const;
    void setCategoryIdFilter(int catId);

    QString searchKeyword() const;
    void setSearchKeyword(const QString &keyword);

    Q_INVOKABLE void loadBudgets();
    Q_INVOKABLE void addBudget(const QString &name, int priority, int categoryId, double limit,
                               const QString &startDateStr, const QString &endDateStr);
    Q_INVOKABLE void updateBudget(int id, const QString &name, int priority, int categoryId, double limit,
                                  const QString &startDateStr, const QString &endDateStr);
    Q_INVOKABLE void deleteBudget(int id);

signals:
    void statsChanged();
    void filterChanged();

private:
    void calculateStats();

    QVector<Budget> m_allBudgets;
    QVector<const Budget*> m_filteredBudgets;

    double m_totalSpent;
    double m_totalLimit;
    double m_totalRemaining;

    int m_priorityFilter;   // -1: All, 0: Low, 1: Medium, 2: High
    int m_categoryIdFilter; // 0: All
    QString m_searchKeyword;
};

#endif // BUDGETS_CONTROLLER_H
