import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: budgetsPage

    color: "#f8fafc"
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // =================================================================
        // 1. PAGE TITLE & DIVIDER LINE
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "Budgets"
                font.family: "Inter"
                font.pixelSize: 32
                font.weight: Font.Bold
                color: "#0f172a"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e2e8f0"
            }
        }

        // =================================================================
        // 2. TOP SUMMARY CARDS (3x PageBox_1)
        // =================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            PageBox_1 {
                boxTitle: "TOTAL SPENT"
                amountText: budgetsController.totalSpent.toLocaleString(Qt.locale(), 'f', 0) + " VND"
                labelText: "Across All Budgets"
            }

            PageBox_1 {
                boxTitle: "TOTAL LIMIT"
                amountText: budgetsController.totalLimit.toLocaleString(Qt.locale(), 'f', 0) + " VND"
                labelText: "Combined Limit"
            }

            PageBox_1 {
                boxTitle: "REMAINING"
                amountText: budgetsController.totalRemaining.toLocaleString(Qt.locale(), 'f', 0) + " VND"
                labelText: "Still Available"
            }
        }

        // =================================================================
        // 3. TABLE CONTAINER (Toolbar + Header + ListView Rows)
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // A. Table Toolbar (Search, Priority filter, Category dropdown, Add Budget)
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 70
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1
                topLeftRadius: 12
                topRightRadius: 12

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 14

                    SearchBar_1 {
                        id: searchBar
                        placeholderText: "Search budget name"
                        Layout.preferredWidth: 260
                        text: budgetsController.searchKeyword
                        onTextEdited: function(newText) { budgetsController.searchKeyword = newText }
                    }

                    RowLayout {
                        spacing: 8

                        UniversalButton_1 {
                            buttonText: "All"
                            _state: budgetsController.priorityFilter === -1 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: budgetsController.priorityFilter = -1
                        }
                        UniversalButton_1 {
                            buttonText: "High"
                            _state: budgetsController.priorityFilter === 2 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: budgetsController.priorityFilter = 2
                        }
                        UniversalButton_1 {
                            buttonText: "Medium"
                            _state: budgetsController.priorityFilter === 1 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: budgetsController.priorityFilter = 1
                        }
                        UniversalButton_1 {
                            buttonText: "Low"
                            _state: budgetsController.priorityFilter === 0 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: budgetsController.priorityFilter = 0
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 24
                        color: "#cbd5e1"
                    }

                    Dropdown_1 {
                        id: categoryFilterDropdown
                        Layout.preferredWidth: 200

                        property var allCats: categoriesController.categoriesList
                        property var filteredCats: allCats.filter(function(c) { return c.parentId === 4; })
                        property var catData: [{id: 0, name: "All Main Categories"}].concat(filteredCats)
                        model: catData.map(function(c) { return c.name; })
                        selectedText: "All Main Categories"

                        onSelected: function(index, value) {
                            if (index >= 0 && index < catData.length) {
                                budgetsController.categoryIdFilter = catData[index].id
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    UniversalButton_1 {
                        buttonText: "+ Add Budget"
                        _state: UniversalButton_1.State_1.State_1_selected
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked: {
                            budgetDialog.reset()
                            budgetDialog.open()
                        }
                    }
                }
            }

            // B. Table Column Header Bar (matching BudgetRow_1 column widths exactly)
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 48
                color: "#f1f5f9"
                border.color: "#e2e8f0"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200
                        Layout.fillHeight: true

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "BUDGET"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }

                    Item {
                        Layout.preferredWidth: 140
                        Layout.fillHeight: true

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "PRIORITY"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }

                    Item {
                        Layout.preferredWidth: 160
                        Layout.fillHeight: true

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "CATEGORY"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }

                    Item {
                        Layout.preferredWidth: 280
                        Layout.fillHeight: true

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "PROGRESS"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }

                    Item {
                        Layout.preferredWidth: 240
                        Layout.fillHeight: true

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "DATE & CYCLE"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }

                    Item {
                        Layout.preferredWidth: 100
                        Layout.fillHeight: true

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "ACTIONS"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }
                }
            }

            // C. Dynamic Data Rows Container
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 0

                boundsBehavior: Flickable.StopAtBounds

                model: budgetsController

                delegate: BudgetRow_1 {
                    width: listView.width
                    budgetName: model.tName
                    priorityVal: model.tPriority === 2 ? Priority_1.Priority_1.Priority_1_high
                                 : (model.tPriority === 0 ? Priority_1.Priority_1.Priority_1_low : Priority_1.Priority_1.Priority_1_medium)
                    categoryText: model.tCategory
                    spentText: model.tSpent
                    limitText: "/ " + model.tLimit + " VND"
                    progressFraction: model.tProgressFraction
                    progressSubText: model.tProgressPercent
                    startDate: model.tStartDate
                    endDate: model.tEndDate
                    periodVal: model.tPeriod

                    onEditClicked: {
                        budgetDialog.reset()
                        budgetDialog.isEditMode = true
                        budgetDialog.budgetId = model.tId
                        budgetDialog.budgetName = model.tName
                        budgetDialog.budgetLimit = model.tLimit
                        budgetDialog.budgetSpent = model.tSpent
                        budgetDialog.setPriority(model.tPriority)
                        budgetDialog.setCategoryId(model.tCategoryId)
                        budgetDialog.setDateStrs(model.tStartDate, model.tEndDate)

                        budgetDialog.open()
                    }
                    onDeleteClicked: {
                        deleteDialog.pendingDeleteId = model.tId
                        deleteDialog.open()
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }
        }
    }

    BudgetDialog {
        id: budgetDialog
        anchors.fill: parent

        onAccepted: {
            var startStr = budgetDialog.startDateField ? budgetDialog.startDateField.selectedDate : ""
            var endStr = budgetDialog.endDateField ? budgetDialog.endDateField.selectedDate : ""
            var limitVal = parseFloat(budgetDialog.budgetLimit.replace(/,/g, '')) || 0.0

            if (isEditMode) {
                budgetsController.updateBudget(
                    budgetId,
                    budgetName,
                    budgetPriority,
                    budgetCategoryId,
                    limitVal,
                    startStr,
                    endStr
                )
            } else {
                budgetsController.addBudget(
                    budgetName,
                    budgetPriority,
                    budgetCategoryId,
                    limitVal,
                    startStr,
                    endStr
                )
            }
        }
    }

    DeleteDialog {
        id: deleteDialog
        property int pendingDeleteId: -1

        onAccepted: {
            if (pendingDeleteId !== -1) {
                budgetsController.deleteBudget(pendingDeleteId)
                pendingDeleteId = -1
            }
        }
        onRejected: {
            pendingDeleteId = -1
        }
    }
}
