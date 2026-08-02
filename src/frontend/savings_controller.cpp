#include "savings_controller.h"
#include "../backend/storage/database_manager.h"
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <algorithm>

SavingsController::SavingsController(QObject *parent)
    : QAbstractListModel(parent),
      m_totalSaved(0.0), m_totalRemaining(0.0), m_completedCount(0),
      m_priorityFilter(-1), m_categoryIdFilter(0)
{
    loadSavings();
}

void SavingsController::loadSavings()
{
    beginResetModel();
    m_allSavings = DatabaseManager::instance().getAllSavings();
    m_filteredSavings.clear();

    m_totalSaved = 0.0;
    m_totalRemaining = 0.0;
    m_completedCount = 0;

    for (const Saving& s : m_allSavings) {
        // Aggregate stats consider ALL savings, regardless of the active filter
        m_totalSaved += s.getCurrent();
        m_totalRemaining += s.getRemainingAmount();
        if (s.isCompleted()) m_completedCount++;

        bool matchPriority = true;
        if (m_priorityFilter != -1 && static_cast<int>(s.getPriority()) != m_priorityFilter) {
            matchPriority = false;
        }

        bool matchCat = true;
        if (m_categoryIdFilter != 0 && s.getCategoryId() != m_categoryIdFilter) {
            matchCat = false;
        }

        bool matchSearch = true;
        if (!m_searchKeyword.isEmpty() && !s.getName().contains(m_searchKeyword, Qt::CaseInsensitive)) {
            matchSearch = false;
        }

        if (matchPriority && matchCat && matchSearch) {
            m_filteredSavings.append(&s);
        }
    }

    std::sort(m_filteredSavings.begin(), m_filteredSavings.end(), [](const Saving* a, const Saving* b) {
        return a->getDueDate() < b->getDueDate();
    });

    endResetModel();
    emit statsChanged();
}

int SavingsController::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_filteredSavings.size();
}

QVariant SavingsController::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_filteredSavings.size())
        return QVariant();

    const Saving* s = m_filteredSavings[index.row()];

    switch (role) {
    case IdRole: return s->getId();
    case NameRole: return s->getName();
    case PriorityRole: return static_cast<int>(s->getPriority());
    case CategoryIdRole: return s->getCategoryId();
    case CategoryNameRole: {
        int catId = s->getCategoryId();
        QString catName = "Uncategorized";
        for (const auto& cat : DatabaseManager::instance().getAllCategories()) {
            if (cat.getId() == catId) {
                catName = cat.getName();
                break;
            }
        }
        return catName;
    }
    case CurrentRole: return QLocale::system().toString(s->getCurrent(), 'f', 0);
    case TargetRole: return QLocale::system().toString(s->getTarget(), 'f', 0);
    case ProgressFractionRole: return s->getProgressPercent() / 100.0;
    case ProgressPercentRole: return QString::number(qRound(s->getProgressPercent())) + "% saved";
    case DueDateRole: return s->getDueDate().toString("dd/MM/yyyy");
    case CompletedRole: return s->isCompleted();
    }
    return QVariant();
}

QHash<int, QByteArray> SavingsController::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "tId";
    roles[NameRole] = "tName";
    roles[PriorityRole] = "tPriority";
    roles[CategoryIdRole] = "tCategoryId";
    roles[CategoryNameRole] = "tCategory";
    roles[CurrentRole] = "tCurrent";
    roles[TargetRole] = "tTarget";
    roles[ProgressFractionRole] = "tProgressFraction";
    roles[ProgressPercentRole] = "tProgressPercent";
    roles[DueDateRole] = "tDueDate";
    roles[CompletedRole] = "tCompleted";
    return roles;
}

double SavingsController::totalSaved() const { return m_totalSaved; }
double SavingsController::totalRemaining() const { return m_totalRemaining; }
int SavingsController::completedCount() const { return m_completedCount; }
int SavingsController::totalCount() const { return m_allSavings.size(); }

int SavingsController::priorityFilter() const { return m_priorityFilter; }
void SavingsController::setPriorityFilter(int filter) {
    if (m_priorityFilter != filter) {
        m_priorityFilter = filter;
        emit filterChanged();
        loadSavings();
    }
}

int SavingsController::categoryIdFilter() const { return m_categoryIdFilter; }
void SavingsController::setCategoryIdFilter(int catId) {
    if (m_categoryIdFilter != catId) {
        m_categoryIdFilter = catId;
        emit filterChanged();
        loadSavings();
    }
}

QString SavingsController::searchKeyword() const { return m_searchKeyword; }
void SavingsController::setSearchKeyword(const QString& keyword) {
    if (m_searchKeyword != keyword) {
        m_searchKeyword = keyword;
        emit filterChanged();
        loadSavings();
    }
}

void SavingsController::addSaving(const QString &name, int priority, int categoryId, double target,
                                   double current, const QString &dueDateStr)
{
    QDate dueDate = QDate::fromString(dueDateStr, "dd/MM/yyyy");
    if (!dueDate.isValid()) dueDate = QDate::currentDate().addMonths(1);

    Priority p = static_cast<Priority>(qBound(0, priority, 2));
    DatabaseManager::instance().addSaving(name, dueDate, target, categoryId, p, current);
    loadSavings();
}

void SavingsController::updateSaving(int id, const QString &name, int priority, int categoryId, double target,
                                      double current, const QString &dueDateStr)
{
    QDate dueDate = QDate::fromString(dueDateStr, "dd/MM/yyyy");
    if (!dueDate.isValid()) dueDate = QDate::currentDate().addMonths(1);

    Priority p = static_cast<Priority>(qBound(0, priority, 2));
    DatabaseManager::instance().updateSaving(id, name, dueDate, target, categoryId, p, current);
    loadSavings();
}

void SavingsController::deleteSaving(int id)
{
    DatabaseManager::instance().deleteSaving(id);
    loadSavings();
}

void SavingsController::contributeToSaving(int id, double amount)
{
    DatabaseManager::instance().contributeToSaving(id, amount);
    loadSavings();
}
