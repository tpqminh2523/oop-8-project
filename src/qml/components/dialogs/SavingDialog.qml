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
    property int savingId: -1
    property string savingName: ""
    property int savingPriority: 1 // 0=Low, 1=Medium, 2=High (matches C++ Priority enum)
    property int savingCategoryId: 0
    property string savingCurrent: "" // "Amount Funded" so far
    property string savingTarget: "" // "Save Goal"
    property alias dueDateField: date_Input_Field
    property bool isValidating: false

    readonly property var priorityNames: ["Low", "Medium", "High"]

    function parseDMY(str) {
        if (!str) return null
        var parts = str.split("/")
        if (parts.length !== 3) return null
        var d = parseInt(parts[0]), m = parseInt(parts[1]), y = parseInt(parts[2])
        if (isNaN(d) || isNaN(m) || isNaN(y)) return null
        return new Date(y, m - 1, d)
    }

    function setDateStr(dateStr) {
        var s = parseDMY(dateStr)
        if (s) date_Input_Field.setDate(s.getDate(), s.getMonth() + 1, s.getFullYear())
    }

    function setCategoryId(catId) {
        var allCats = categoriesController.categoriesList
        var list = allCats.filter(function(c) { return c.parentId === 5 })
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === catId) {
                dropdown_3.selectedIndex = i
                dropdown_3.selectedText = list[i].name
                savingCategoryId = list[i].id
                return
            }
        }
        if (list.length > 0) {
            dropdown_3.selectedIndex = 0
            dropdown_3.selectedText = list[0].name
            savingCategoryId = list[0].id
        }
    }

    function setPriority(p) {
        savingPriority = p
        dropdown_1.selectedIndex = p
        dropdown_1.selectedText = priorityNames[p]
    }

    function open() { visible = true }
    function close() { visible = false }

    function reset() {
        isEditMode = false
        savingId = -1
        savingName = ""
        savingCurrent = ""
        savingTarget = ""
        isValidating = false
        textField.text = ""
        date_Input_Field.clear()
        setPriority(1) // Medium

        var allCats = categoriesController.categoriesList
        var list = allCats.filter(function(c) { return c.parentId === 5 })
        if (list.length > 0) {
            dropdown_3.selectedIndex = 0
            dropdown_3.selectedText = list[0].name
            savingCategoryId = list[0].id
        } else {
            savingCategoryId = 0
            dropdown_3.selectedText = "Select Category"
        }
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
        id: savingDialog
        anchors.centerIn: parent

        height: 493
        width: 500

        color: "#ffffff"
        radius: 15
        clip: true

        // Absorb clicks inside the card so they don't reach the dimmed overlay
        MouseArea { anchors.fill: parent }

        // 1. Header Title
        Image {
            id: title
            source: Qt.resolvedUrl("../../assets/title_11.png")

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
                text: root.isEditMode ? "Edit Saving" : "Add Saving"
                textFormat: Text.PlainText
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
            }
        }

        // 2. Saving Title Field
        Rectangle {
            id: titleInput
            y: 75
            height: 74
            width: 500
            color: "transparent"

            Text {
                id: saving_Title
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
                text: "Saving Title"
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
                border.color: (root.isValidating && root.savingName.trim() === "") ? "red" : "transparent"
                border.width: (root.isValidating && root.savingName.trim() === "") ? 1 : 0

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
                    text: root.savingName
                    onTextChanged: root.savingName = text

                    Text {
                        text: "e.g. Emergency Fund"
                        color: "#8049454f"
                        font: parent.font
                        visible: !parent.text && !parent.activeFocus
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // 3. Priority, Categories, Amount Funded & Save Goal Grid Row
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
                    selectedText: root.priorityNames[root.savingPriority]

                    onSelected: function(index, value) {
                        root.savingPriority = index
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
                    property var catList: allCats.filter(function(c) { return c.parentId === 5 })
                    model: catList.map(function(c) { return c.name })

                    onSelected: function(index, value) {
                        if (index >= 0 && index < catList.length) {
                            root.savingCategoryId = catList[index].id
                        }
                    }
                }
            }

            // Amount Funded Input (current saved amount - editable)
            Rectangle {
                id: dropdown_4
                x: 20
                y: 76
                height: 66
                width: 225
                color: "transparent"

                Text {
                    id: amount_Funded
                    height: 32
                    width: 226
                    color: "#878787"
                    font.family: "Intel One Mono"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    lineHeight: 32
                    lineHeightMode: Text.FixedHeight
                    text: "Amount Funded"
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignTop
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    id: inputBox_1
                    y: 32
                    height: 34
                    width: 225
                    color: "#e9e9e9"
                    radius: 10

                    TextInput {
                        id: supporting_text
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
                        text: root.savingCurrent
                        onTextChanged: {
                            if (activeFocus) {
                                var raw = text.replace(/[^0-9]/g, "")
                                var formatted = raw.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                                if (text !== formatted) {
                                    text = formatted
                                }
                                root.savingCurrent = formatted
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

            // Save Goal Input (target amount)
            Rectangle {
                id: dropdown_5
                x: 255
                y: 76
                height: 66
                width: 225
                color: "transparent"

                Text {
                    id: save_Goal
                    height: 32
                    width: 226
                    color: "#878787"
                    font.family: "Intel One Mono"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignLeft
                    lineHeight: 32
                    lineHeightMode: Text.FixedHeight
                    text: "Save Goal"
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
                    border.color: (root.isValidating && root.savingTarget.trim() === "") ? "red" : "transparent"
                    border.width: (root.isValidating && root.savingTarget.trim() === "") ? 1 : 0

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
                        text: root.savingTarget
                        onTextChanged: {
                            if (activeFocus) {
                                var raw = text.replace(/[^0-9]/g, "")
                                var formatted = raw.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                                if (text !== formatted) {
                                    text = formatted
                                }
                                root.savingTarget = formatted
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

        // 4. Due Date Field
        Rectangle {
            id: dueDate
            y: 341
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
                text: "Due Date"
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
            }
        }

        // 5. Footer Action Buttons
        Image {
            id: choice
            y: 440
            source: Qt.resolvedUrl("../../assets/choice_2.png")

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
                        if (root.savingName.trim() === "" || root.savingTarget.trim() === ""
                            || date_Input_Field.selectedDate.trim() === "" || root.savingCategoryId === 0) {
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
