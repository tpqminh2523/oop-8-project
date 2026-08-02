#include "budgets_controller.h"
#include "../backend/storage/database_manager.h"
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <algorithm>

BudgetsController::BudgetsController(QObject *parent)
    : QAbstractListModel(parent),
      m_totalSpent(0.0), m_totalLimit(0.0), m_totalRemaining(0.0),
      m_priorityFilter(-1), m_categoryIdFilter(0)
{
    loadBudgets();
}

void BudgetsController::loadBudgets()
{
    beginResetModel();
    m_allBudgets = DatabaseManager::instance().getAllBudgets();
    m_filteredBudgets.clear();

    m_totalSpent = 0.0;
    m_totalLimit = 0.0;
    m_totalRemaining = 0.0;

    for (const Budget& b : m_allBudgets) {
        // Aggregate stats consider ALL budgets, regardless of the active filter
        m_totalSpent += b.getSpent();
        m_totalLimit += b.getLimit();
        m_totalRemaining += b.getRemainingAmount();

        bool matchPriority = true;
        if (m_priorityFilter != -1 && static_cast<int>(b.getPriority()) != m_priorityFilter) {
            matchPriority = false;
        }

        bool matchCat = true;
        if (m_categoryIdFilter != 0 && b.getCategoryId() != m_categoryIdFilter) {
            matchCat = false;
        }

        bool matchSearch = true;
        if (!m_searchKeyword.isEmpty() && !b.getName().contains(m_searchKeyword, Qt::CaseInsensitive)) {
            matchSearch = false;
        }

        if (matchPriority && matchCat && matchSearch) {
            m_filteredBudgets.append(&b);
        }
    }

    std::sort(m_filteredBudgets.begin(), m_filteredBudgets.end(), [](const Budget* a, const Budget* b) {
        return a->getEndDate() < b->getEndDate();
    });

    endResetModel();
    emit statsChanged();
}

int BudgetsController::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_filteredBudgets.size();
}

QVariant BudgetsController::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_filteredBudgets.size())
        return QVariant();

    const Budget* b = m_filteredBudgets[index.row()];

    switch (role) {
    case IdRole: return b->getId();
    case NameRole: return b->getName();
    case PriorityRole: return static_cast<int>(b->getPriority());
    case CategoryIdRole: return b->getCategoryId();
    case CategoryNameRole: {
        int catId = b->getCategoryId();
        QString catName = "Uncategorized";
        for (const auto& cat : DatabaseManager::instance().getAllCategories()) {
            if (cat.getId() == catId) {
                catName = cat.getName();
                break;
            }
        }
        return catName;
    }
    case SpentRole: return QLocale::system().toString(b->getSpent(), 'f', 0);
    case LimitRole: return QLocale::system().toString(b->getLimit(), 'f', 0);
    case ProgressFractionRole: {
        double limit = b->getLimit();
        if (limit <= 0) return 0.0;
        return std::min(b->getSpent() / limit, 1.0);
    }
    case ProgressPercentRole: {
        double percent = b->getProgressPercent();
        return QString::number(qRound(percent)) + "% spent";
    }
    case StartDateRole: return b->getStartDate().toString("dd/MM/yyyy");
    case EndDateRole: return b->getEndDate().toString("dd/MM/yyyy");
    case PeriodRole: {
        // Budget has no persisted "cycle" field, so derive a display cycle from the
        // start/end date span: <=8 days -> Weekly, <=35 days -> Monthly, else Yearly.
        int days = b->getStartDate().daysTo(b->getEndDate());
        if (days <= 8) return 0;      // Weekly
        if (days <= 35) return 1;     // Monthly
        return 2;                     // Yearly
    }
    }
    return QVariant();
}

QHash<int, QByteArray> BudgetsController::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "tId";
    roles[NameRole] = "tName";
    roles[PriorityRole] = "tPriority";
    roles[CategoryIdRole] = "tCategoryId";
    roles[CategoryNameRole] = "tCategory";
    roles[SpentRole] = "tSpent";
    roles[LimitRole] = "tLimit";
    roles[ProgressFractionRole] = "tProgressFraction";
    roles[ProgressPercentRole] = "tProgressPercent";
    roles[StartDateRole] = "tStartDate";
    roles[EndDateRole] = "tEndDate";
    roles[PeriodRole] = "tPeriod";
    return roles;
}

double BudgetsController::totalSpent() const { return m_totalSpent; }
double BudgetsController::totalLimit() const { return m_totalLimit; }
double BudgetsController::totalRemaining() const { return m_totalRemaining; }

int BudgetsController::priorityFilter() const { return m_priorityFilter; }
void BudgetsController::setPriorityFilter(int filter) {
    if (m_priorityFilter != filter) {
        m_priorityFilter = filter;
        emit filterChanged();
        loadBudgets();
    }
}

int BudgetsController::categoryIdFilter() const { return m_categoryIdFilter; }
void BudgetsController::setCategoryIdFilter(int catId) {
    if (m_categoryIdFilter != catId) {
        m_categoryIdFilter = catId;
        emit filterChanged();
        loadBudgets();
    }
}

QString BudgetsController::searchKeyword() const { return m_searchKeyword; }
void BudgetsController::setSearchKeyword(const QString& keyword) {
    if (m_searchKeyword != keyword) {
        m_searchKeyword = keyword;
        emit filterChanged();
        loadBudgets();
    }
}

void BudgetsController::addBudget(const QString &name, int priority, int categoryId, double limit,
                                   const QString &startDateStr, const QString &endDateStr)
{
    QDate startDate = QDate::fromString(startDateStr, "dd/MM/yyyy");
    QDate endDate = QDate::fromString(endDateStr, "dd/MM/yyyy");
    if (!startDate.isValid()) startDate = QDate::currentDate();
    if (!endDate.isValid()) endDate = startDate.addMonths(1);

    Priority p = static_cast<Priority>(qBound(0, priority, 2));
    DatabaseManager::instance().addBudget(name, p, categoryId, limit, startDate, endDate);
    loadBudgets();
}

void BudgetsController::updateBudget(int id, const QString &name, int priority, int categoryId, double limit,
                                      const QString &startDateStr, const QString &endDateStr)
{
    QDate startDate = QDate::fromString(startDateStr, "dd/MM/yyyy");
    QDate endDate = QDate::fromString(endDateStr, "dd/MM/yyyy");
    if (!startDate.isValid()) startDate = QDate::currentDate();
    if (!endDate.isValid()) endDate = startDate.addMonths(1);

    Priority p = static_cast<Priority>(qBound(0, priority, 2));
    DatabaseManager::instance().updateBudget(id, name, p, categoryId, limit, startDate, endDate);
    loadBudgets();
}

void BudgetsController::deleteBudget(int id)
{
    DatabaseManager::instance().deleteBudget(id);
    loadBudgets();
}
