import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent
    visible: false
    z: 999

    signal accepted()
    signal rejected()

    property bool isEditMode: false
    property int budgetId: -1
    property string budgetName: ""
    property int budgetPriority: 1 // 0=Low, 1=Medium, 2=High (matches C++ Priority enum)
    property int budgetCategoryId: 0
    property string budgetSpent: "0" // display-only, not directly editable by the user
    property string budgetLimit: ""
    property alias startDateField: date_Input_Field
    property alias endDateField: date_Input_Field_1
    property bool isValidating: false

    readonly property var priorityNames: ["Low", "Medium", "High"]
    readonly property var periodNames: ["Weekly", "Monthly", "Yearly"]

    function pad(n) { return n < 10 ? "0" + n : "" + n }

    function parseDMY(str) {
        if (!str) return null
        var parts = str.split("/")
        if (parts.length !== 3) return null
        var d = parseInt(parts[0]), m = parseInt(parts[1]), y = parseInt(parts[2])
        if (isNaN(d) || isNaN(m) || isNaN(y)) return null
        return new Date(y, m - 1, d)
    }

    function setDateStrs(startStr, endStr) {
        var s = parseDMY(startStr)
        if (s) date_Input_Field.setDate(s.getDate(), s.getMonth() + 1, s.getFullYear())
        var e = parseDMY(endStr)
        if (e) date_Input_Field_1.setDate(e.getDate(), e.getMonth() + 1, e.getFullYear())
    }

    function setCategoryId(catId) {
        var allCats = categoriesController.categoriesList
        var list = allCats.filter(function(c) { return c.parentId === 4 })
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === catId) {
                dropdown_3.selectedIndex = i
                dropdown_3.selectedText = list[i].name
                budgetCategoryId = list[i].id
                return
            }
        }
        if (list.length > 0) {
            dropdown_3.selectedIndex = 0
            dropdown_3.selectedText = list[0].name
            budgetCategoryId = list[0].id
        }
    }

    function setPriority(p) {
        budgetPriority = p
        dropdown_1.selectedIndex = p
        dropdown_1.selectedText = priorityNames[p]
    }

    // Auto-fill the End Date whenever Start Date or Period changes, so the user
    // doesn't have to compute the end date by hand. They can still edit it manually afterwards.
    function recomputeEndDate() {
        var start = parseDMY(date_Input_Field.selectedDate)
        if (!start) return
        var end = new Date(start.getTime())
        if (dropdown_7.selectedIndex === 0) end.setDate(end.getDate() + 7)             // Weekly
        else if (dropdown_7.selectedIndex === 2) end.setFullYear(end.getFullYear() + 1) // Yearly
        else end.setMonth(end.getMonth() + 1)                                            // Monthly (default)
        date_Input_Field_1.setDate(end.getDate(), end.getMonth() + 1, end.getFullYear())
    }

    function open() { visible = true }
    function close() { visible = false }

    function reset() {
        isEditMode = false
        budgetId = -1
        budgetName = ""
        budgetLimit = ""
        budgetSpent = "0"
        isValidating = false
        textField.text = ""
        date_Input_Field.clear()
        date_Input_Field_1.clear()
        setPriority(1) // Medium
        dropdown_7.selectedIndex = 1
        dropdown_7.selectedText = periodNames[1] // Monthly

        var allCats = categoriesController.categoriesList
        var list = allCats.filter(function(c) { return c.parentId === 4 })
        if (list.length > 0) {
            dropdown_3.selectedIndex = 0
            dropdown_3.selectedText = list[0].name
            budgetCategoryId = list[0].id
        } else {
            budgetCategoryId = 0
            dropdown_3.selectedText = "Select Category"
        }

        // Default Start Date to today so the period auto-fill has something to work from
        var today = new Date()
        date_Input_Field.setDate(today.getDate(), today.getMonth() + 1, today.getFullYear())
        recomputeEndDate()
    }

    // Dimmed background overlay
    Rectangle {
        anchors.fill: parent
        color: "#66000000"

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Centered Dialog Card
    Rectangle {
        id: budgetDialog
        anchors.centerIn: parent

        height: 683
        width: 500

        color: "#ffffff"
        radius: 15
        clip: true

        // Absorb clicks inside the card so they don't reach the dimmed overlay
        MouseArea { anchors.fill: parent }

        // 1. Title Header
        Image {
            id: title
            source: Qt.resolvedUrl("../../assets/title_9.png")

            Text {
                id: title_1
                x: 20
                y: 9
                height: 32
                width: 461
                color: "#191919"
                font.capitalization: Font.Capitalize
                font.family: "Intel One Mono"
                font.pixelSize: 24
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
                lineHeight: 32
                lineHeightMode: Text.FixedHeight
                text: root.isEditMode ? "Edit Budget" : "Add Budget"
                textFormat: Text.PlainText
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
            }
        }

        // 2. Budget Title Field
        Rectangle {
            id: titleInput
            y: 75
            height: 74
            width: 500
            color: "transparent"

            Text {
                id: budget_Title
                x: 20
                height: 32
                width: 461
                color: "#878787"
                font.family: "Intel One Mono"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
                lineHeight: 32
                lineHeightMode: Text.FixedHeight
                text: "Budget Title"
                textFormat: Text.PlainText
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
            }

            Rectangle {
                id: inputBox
                x: 20
                y: 32
                height: 42
                width: 460
                color: "#e9e9e9"
                radius: 10
                border.color: (root.isValidating && root.budgetName.trim() === "") ? "red" : "transparent"
                border.width: (root.isValidating && root.budgetName.trim() === "") ? 1 : 0

                TextInput {
                    id: textField
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    verticalAlignment: Text.AlignVCenter
                    color: "#191919"
                    font.family: "Roboto"
                    font.pixelSize: 16
                    font.weight: Font.Normal
                    clip: true
                    selectByMouse: true
                    maximumLength: 40
                    text: root.budgetName
                    onTextChanged: root.budgetName = text

                    Text {
                        text: "e.g. Monthly Living Budget"
                        color: "#8049454f"
                        font: parent.font
                        visible: !parent.text && !parent.activeFocus
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // 3. Priority, Categories, Amount Spent & Budget Limit Grid Row
        Rectangle {
            id: rowContainer
            y: 174
            height: 142
            width: 500
            color: "transparent"

            // Priority Dropdown
            Rectangle {
                id: dropdown
                x: 20
                height: 66
                width: 225
                color: "transparent"

                Text {
                    id: priority
                    height: 32
                    width: 226
                    color: "#878787"
                    font.family: "Intel One Mono"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    lineHeight: 32
                    lineHeightMode: Text.FixedHeight
                    text: "Priority"
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignTop
                    wrapMode: Text.Wrap
                }

                Dropdown_1 {
                    id: dropdown_1
                    y: 32
                    height: 34
                    width: 225
                    _state: Dropdown_1.State_1.State_1_default
                    clip: true
                    model: root.priorityNames
                    selectedText: root.priorityNames[root.budgetPriority]

                    onSelected: function(index, value) {
                        root.budgetPriority = index
                    }
                }
            }

            // Categories Dropdown
            Rectangle {
                id: dropdown_2
                x: 255
                height: 66
                width: 225
                color: "transparent"

                Text {
                    id: categories
                    height: 32
                    width: 226
                    color: "#878787"
                    font.family: "Intel One Mono"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    lineHeight: 32
                    lineHeightMode: Text.FixedHeight
                    text: "Categories"
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignTop
                    wrapMode: Text.Wrap
                }

                Dropdown_1 {
                    id: dropdown_3
                    y: 32
                    height: 34
                    width: 225
                    _state: Dropdown_1.State_1.State_1_default
                    clip: true

                    property var allCats: categoriesController.categoriesList
                    property var catList: allCats.filter(function(c) { return c.parentId === 4 })
                    model: catList.map(function(c) { return c.name })

                    onSelected: function(index, value) {
                        if (index >= 0 && index < catList.length) {
                            root.budgetCategoryId = catList[index].id
                        }
                    }
                }
            }

            // Amount Spent (read-only; accumulates automatically from expense transactions)
            Rectangle {
                id: dropdown_4
                x: 20
                y: 76
                height: 66
                width: 225
                color: "transparent"

                Text {
                    id: amount_Spent
                    height: 32
                    width: 226
                    color: "#878787"
                    font.family: "Intel One Mono"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    lineHeight: 32
                    lineHeightMode: Text.FixedHeight
                    text: "Amount Spent"
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignTop
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    id: inputBox_1
                    y: 32
                    height: 34
                    width: 225
                    color: "#f1f5f9"
                    radius: 10

                    TextInput {
                        id: supporting_text
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        verticalAlignment: Text.AlignVCenter
                        color: "#94a3b8"
                        font.family: "Roboto"
                        font.pixelSize: 16
                        font.weight: Font.Normal
                        clip: true
                        readOnly: true
                        text: root.budgetSpent + " VND"

                        Text {
                            text: root.isEditMode ? "" : "Starts at 0"
                            color: "#8049454f"
                            font: parent.font
                            visible: !parent.text && !parent.activeFocus
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Budget Limit Input
            Rectangle {
                id: dropdown_5
                x: 255
                y: 76
                height: 66
                width: 225
                color: "transparent"

                Text {
                    id: budget_Limit
                    height: 32
                    width: 226
                    color: "#878787"
                    font.family: "Intel One Mono"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    lineHeight: 32
                    lineHeightMode: Text.FixedHeight
                    text: "Budget Limit"
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignTop
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    id: inputBox_2
                    y: 32
                    height: 34
                    width: 225
                    color: "#e9e9e9"
                    radius: 10
                    border.color: (root.isValidating && root.budgetLimit.trim() === "") ? "red" : "transparent"
                    border.width: (root.isValidating && root.budgetLimit.trim() === "") ? 1 : 0

                    TextInput {
                        id: supporting_text_1
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        verticalAlignment: Text.AlignVCenter
                        color: "#191919"
                        font.family: "Roboto"
                        font.pixelSize: 16
                        font.weight: Font.Normal
                        clip: true
                        selectByMouse: true
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        text: root.budgetLimit
                        onTextChanged: {
                            if (activeFocus) {
                                var raw = text.replace(/[^0-9]/g, "")
                                var formatted = raw.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                                if (text !== formatted) {
                                    text = formatted
                                }
                                root.budgetLimit = formatted
                            }
                        }

                        Text {
                            text: "0"
                            color: "#8049454f"
                            font: parent.font
                            visible: !parent.text && !parent.activeFocus
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // 4. Start Date Field
        Rectangle {
            id: startDate
            y: 341
            height: 74
            width: 500
            color: "transparent"

            Text {
                id: start_Date
                x: 20
                height: 32
                width: 461
                color: "#878787"
                font.family: "Intel One Mono"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
                lineHeight: 32
                lineHeightMode: Text.FixedHeight
                text: "Start Date"
                textFormat: Text.PlainText
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
            }

            Date_Input_Field_1 {
                id: date_Input_Field
                x: 20
                y: 32
                height: 42
                width: 460
                border.color: (root.isValidating && date_Input_Field.selectedDate.trim() === "") ? "red" : "transparent"
                border.width: (root.isValidating && date_Input_Field.selectedDate.trim() === "") ? 1 : 0

                onSelectedDateChanged: root.recomputeEndDate()
            }
        }

        // 5. End Date Field
        Rectangle {
            id: dueDate
            y: 440
            height: 74
            width: 500
            color: "transparent"

            Text {
                id: due_Date
                x: 20
                height: 32
                width: 461
                color: "#878787"
                font.family: "Intel One Mono"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
                lineHeight: 32
                lineHeightMode: Text.FixedHeight
                text: "End Date"
                textFormat: Text.PlainText
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
            }

            Date_Input_Field_1 {
                id: date_Input_Field_1
                x: 20
                y: 32
                height: 42
                width: 460
                border.color: (root.isValidating && date_Input_Field_1.selectedDate.trim() === "") ? "red" : "transparent"
                border.width: (root.isValidating && date_Input_Field_1.selectedDate.trim() === "") ? 1 : 0
            }
        }

        // 6. Period Field (convenience: auto-fills End Date from Start Date + period)
        Rectangle {
            id: dropdown_6
            y: 539
            height: 66
            width: 500
            color: "transparent"

            Text {
                id: period
                x: 20
                height: 32
                width: 461
                color: "#878787"
                font.family: "Intel One Mono"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignLeft
                lineHeight: 32
                lineHeightMode: Text.FixedHeight
                text: "Period"
                textFormat: Text.PlainText
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
            }

            Dropdown_1 {
                id: dropdown_7
                x: 20
                y: 32
                height: 34
                width: 460
                _state: Dropdown_1.State_1.State_1_default
                clip: true
                model: root.periodNames
                selectedText: root.periodNames[1]

                onSelected: function(index, value) {
                    root.recomputeEndDate()
                }
            }
        }

        // 7. Footer Action Buttons
        Image {
            id: choice
            y: 630
            source: Qt.resolvedUrl("../../assets/choice.png")

            UniversalButton_1 {
                id: cancelButton
                x: 305
                y: 9
                buttonText: "Cancel"
                height: 35
                width: 75
                _state: UniversalButton_1.State_1.State_1_default

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.rejected()
                        root.close()
                    }
                }
            }

            UniversalButton_1 {
                id: saveButton
                x: 405
                y: 9
                buttonText: root.isEditMode ? "Save" : "Add"
                height: 35
                width: 75
                _state: UniversalButton_1.State_1.State_1_selected

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.isValidating = true
                        if (root.budgetName.trim() === "" || root.budgetLimit.trim() === ""
                            || date_Input_Field.selectedDate.trim() === "" || date_Input_Field_1.selectedDate.trim() === ""
                            || root.budgetCategoryId === 0) {
                            return
                        }
                        root.accepted()
                        root.close()
                    }
                }
            }
        }
    }
}
