import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: savingsPage

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
                text: "Savings"
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
                boxTitle: "TOTAL SAVED"
                amountText: savingsController.totalSaved.toLocaleString(Qt.locale(), 'f', 0) + " VND"
                labelText: "Across All Goals"
            }

            PageBox_1 {
                boxTitle: "REMAINING"
                amountText: savingsController.totalRemaining.toLocaleString(Qt.locale(), 'f', 0) + " VND"
                labelText: "To Reach All Targets"
            }

            PageBox_1 {
                boxTitle: "COMPLETED"
                amountText: savingsController.completedCount + " / " + savingsController.totalCount
                labelText: "Goals Fully Funded"
            }
        }

        // =================================================================
        // 3. TABLE CONTAINER (Toolbar + Header + ListView Rows)
        // =================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // A. Table Toolbar (Search, Priority Filters, Dropdown, Add Saving Button)
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
                        placeholderText: "Search Saving"
                        Layout.preferredWidth: 260
                        text: savingsController.searchKeyword
                        onTextEdited: function(newText) { savingsController.searchKeyword = newText }
                    }

                    RowLayout {
                        spacing: 8

                        UniversalButton_1 {
                            buttonText: "All"
                            _state: savingsController.priorityFilter === -1 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: savingsController.priorityFilter = -1
                        }
                        UniversalButton_1 {
                            buttonText: "High"
                            _state: savingsController.priorityFilter === 2 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: savingsController.priorityFilter = 2
                        }
                        UniversalButton_1 {
                            buttonText: "Medium"
                            _state: savingsController.priorityFilter === 1 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: savingsController.priorityFilter = 1
                        }
                        UniversalButton_1 {
                            buttonText: "Low"
                            _state: savingsController.priorityFilter === 0 ? UniversalButton_1.State_1.State_1_selected : UniversalButton_1.State_1.State_1_default
                            onClicked: savingsController.priorityFilter = 0
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
                        property var filteredCats: allCats.filter(function(c) { return c.parentId === 5; })
                        property var catData: [{id: 0, name: "All Main Categories"}].concat(filteredCats)
                        model: catData.map(function(c) { return c.name; })
                        selectedText: "All Main Categories"

                        onSelected: function(index, value) {
                            if (index >= 0 && index < catData.length) {
                                savingsController.categoryIdFilter = catData[index].id
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    UniversalButton_1 {
                        buttonText: "+ Add Saving"
                        _state: UniversalButton_1.State_1.State_1_selected
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked: {
                            savingDialog.reset()
                            savingDialog.open()
                        }
                    }
                }
            }

            // B. Table Column Header Bar (Matching SavingRow_1 column wrappers)
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

                    // 1. SAVING
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200
                        Layout.fillHeight: true

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "SAVING"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }

                    // 2. PRIORITY
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

                    // 3. CATEGORY
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

                    // 4. PROGRESS
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

                    // 5. DUE DATE
                    Item {
                        Layout.preferredWidth: 180
                        Layout.fillHeight: true

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "DUE DATE"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#64748b"
                        }
                    }

                    // 6. ACTIONS
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

            // C. Dynamic Row ListView
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 0

                boundsBehavior: Flickable.StopAtBounds

                model: savingsController

                delegate: SavingRow_1 {
                    width: listView.width
                    savingName: model.tName
                    priorityVal: model.tPriority === 2 ? Priority_1.Priority_1.Priority_1_high
                                 : (model.tPriority === 0 ? Priority_1.Priority_1.Priority_1_low : Priority_1.Priority_1.Priority_1_medium)
                    categoryText: model.tCategory
                    savedText: model.tCurrent
                    goalText: "/ " + model.tTarget + " VND"
                    progressFraction: model.tProgressFraction
                    progressSubText: model.tProgressPercent
                    dueDateText: model.tDueDate

                    onEditClicked: {
                        savingDialog.reset()
                        savingDialog.isEditMode = true
                        savingDialog.savingId = model.tId
                        savingDialog.savingName = model.tName
                        savingDialog.savingTarget = model.tTarget
                        savingDialog.savingCurrent = model.tCurrent
                        savingDialog.setPriority(model.tPriority)
                        savingDialog.setCategoryId(model.tCategoryId)
                        savingDialog.setDateStr(model.tDueDate)

                        savingDialog.open()
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

    SavingDialog {
        id: savingDialog
        anchors.fill: parent

        onAccepted: {
            var dueStr = savingDialog.dueDateField ? savingDialog.dueDateField.selectedDate : ""
            var targetVal = parseFloat(savingDialog.savingTarget.replace(/,/g, '')) || 0.0
            var currentVal = parseFloat(savingDialog.savingCurrent.replace(/,/g, '')) || 0.0

            if (isEditMode) {
                savingsController.updateSaving(
                    savingId,
                    savingName,
                    savingPriority,
                    savingCategoryId,
                    targetVal,
                    currentVal,
                    dueStr
                )
            } else {
                savingsController.addSaving(
                    savingName,
                    savingPriority,
                    savingCategoryId,
                    targetVal,
                    currentVal,
                    dueStr
                )
            }
        }
    }

    DeleteDialog {
        id: deleteDialog
        property int pendingDeleteId: -1

        onAccepted: {
            if (pendingDeleteId !== -1) {
                savingsController.deleteSaving(pendingDeleteId)
                pendingDeleteId = -1
            }
        }
        onRejected: {
            pendingDeleteId = -1
        }
    }
}
