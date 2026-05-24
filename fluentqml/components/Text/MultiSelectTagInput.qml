import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import Qt5Compat.GraphicalEffects
import "../../themes"
import "../../components"

Control {
    id: root

    property var model: []
    property var selectedItems: []
    property string textRole: "text"
    property string placeholderText: ""
    property bool editable: true
    property bool allowCustomText: false
    property int maximumMenuHeight: 350
    property color primaryColor: Theme.currentTheme.colors.primaryColor
    property alias inputControl: input
    readonly property bool inputActive: root.activeFocus || input.activeFocus

    signal itemAdded(var item)
    signal itemRemoved(var item)
    signal accepted(var items)

    function itemText(item) {
        if (typeof item === "string")
            return item
        return item[textRole]
    }

    function containsItem(item) {
        let text = itemText(item)
        for (let i = 0; i < selectedItems.length; i++) {
            if (itemText(selectedItems[i]) === text)
                return true
        }
        return false
    }

    function availableItems() {
        let items = []
        let keyword = inputControl.text.toLowerCase()

        if (model instanceof ListModel) {
            for (let i = 0; i < model.count; i++) {
                let item = model.get(i)
                let text = itemText(item)
                if (!containsItem(item) && text.toLowerCase().includes(keyword))
                    items.push(item)
            }
        } else if (Array.isArray(model)) {
            for (let j = 0; j < model.length; j++) {
                let value = model[j]
                let valueText = itemText(value)
                if (!containsItem(value) && valueText.toLowerCase().includes(keyword))
                    items.push(value)
            }
        }

        return items
    }

    function refreshMenu() {
        filteredModel.model = availableItems()
        filteredModel.currentIndex = -1
    }

    function openMenu() {
        if (!editable)
            return
        if (!suggestionsPopup.visible)
            refreshMenu()
        suggestionsPopup.open()
    }

    function focusAndOpenMenu() {
        inputControl.forceActiveFocus()
        openMenu()
    }

    function moveCurrentIndex(step) {
        if (!suggestionsPopup.visible)
            openMenu()
        if (filteredModel.count === 0)
            return

        let index = filteredModel.currentIndex + step
        if (index < 0)
            index = filteredModel.count - 1
        else if (index >= filteredModel.count)
            index = 0

        filteredModel.currentIndex = index
        filteredModel.positionViewAtIndex(index, ListView.Contain)
    }

    function addItem(item) {
        if (containsItem(item))
            return

        let items = selectedItems.slice()
        items.push(item)
        selectedItems = items
        inputControl.text = ""
        refreshMenu()
        itemAdded(item)
        accepted(selectedItems)
    }

    function removeItem(index) {
        if (index < 0 || index >= selectedItems.length)
            return

        let items = selectedItems.slice()
        let removed = items.splice(index, 1)[0]
        selectedItems = items
        refreshMenu()
        itemRemoved(removed)
        accepted(selectedItems)
    }

    function commitInput() {
        if (filteredModel.currentIndex >= 0 && filteredModel.currentIndex < filteredModel.count) {
            addItem(filteredModel.model[filteredModel.currentIndex])
            return
        }

        if (allowCustomText && inputControl.text.length > 0)
            addItem(inputControl.text)
    }

    function handleInputKey(event) {
        if (event.key === Qt.Key_Backspace && inputControl.text.length === 0 && selectedItems.length > 0) {
            removeItem(selectedItems.length - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            commitInput()
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            moveCurrentIndex(1)
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            moveCurrentIndex(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            suggestionsPopup.close()
            event.accepted = true
        }
    }

    enabled: editable
    implicitWidth: 240
    implicitHeight: Math.max(34, tagFlow.implicitHeight + 10)
    leftPadding: 8
    rightPadding: 36
    topPadding: 6
    bottomPadding: 6
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true

    FocusIndicator {
        control: parent
    }

    background: Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.currentTheme.appearance.buttonRadius
        color: root.inputActive
            ? Theme.currentTheme.colors.controlInputActiveColor
            : root.hovered
                ? Theme.currentTheme.colors.controlSecondaryColor
                : Theme.currentTheme.colors.controlColor
        border.width: Theme.currentTheme.appearance.borderWidth
        border.color: Theme.currentTheme.colors.controlBorderColor
        clip: true

        layer.enabled: true
        layer.smooth: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: background.width
                height: background.height
                radius: background.radius
            }
        }

        Rectangle {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            radius: 999
            height: root.inputActive
                ? Theme.currentTheme.appearance.borderWidth * 2
                : Theme.currentTheme.appearance.borderWidth
            color: root.inputActive
                ? root.primaryColor
                : Theme.currentTheme.colors.textControlBorderColor
        }

        Behavior on color { ColorAnimation { duration: Utils.animationSpeed; easing.type: Easing.OutQuint } }
    }

    contentItem: Item {
        implicitHeight: tagFlow.implicitHeight

        Flow {
            id: tagFlow
            width: parent.width
            spacing: 6
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: root.selectedItems

                Rectangle {
                    height: 22
                    width: chipRow.implicitWidth + 12
                    radius: 5
                    color: Qt.alpha(root.primaryColor, 0.10)
                    border.width: Theme.currentTheme.appearance.borderWidth
                    border.color: Qt.alpha(root.primaryColor, 0.18)

                    Row {
                        id: chipRow
                        anchors.left: parent.left
                        anchors.leftMargin: 7
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        spacing: 3

                        Text {
                            width: Math.min(implicitWidth, Math.max(40, root.width - 68))
                            height: parent.height
                            typography: Typography.Caption
                            text: root.itemText(modelData)
                            color: Theme.currentTheme.colors.textAccentColor
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        ToolButton {
                            flat: true
                            width: 16
                            height: 16
                            anchors.verticalCenter: parent.verticalCenter
                            focusPolicy: Qt.NoFocus
                            icon.name: "ic_fluent_dismiss_20_regular"
                            size: 10
                            color: Theme.currentTheme.colors.textAccentColor
                            hoverable: root.editable
                            onClicked: root.removeItem(index)
                        }
                    }
                }
            }

            Item {
                width: root.selectedItems.length === 0
                    ? Math.max(80, tagFlow.width - 4)
                    : Math.max(14, Math.min(180, root.inputControl.contentWidth + 14))
                height: 22

                Text {
                    anchors.fill: parent
                    typography: Typography.Body
                    color: Theme.currentTheme.colors.textSecondaryColor
                    text: root.placeholderText
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    visible: root.selectedItems.length === 0 && root.inputControl.text.length === 0 && !root.inputControl.activeFocus
                }

                TextInput {
                    id: input
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    typography: Typography.Body
                    clip: true
                    selectByMouse: true
                    color: Theme.currentTheme.colors.textColor
                    selectionColor: Theme.currentTheme.colors.primaryColor
                    selectedTextColor: Theme.currentTheme.colors.textOnAccentColor
                    cursorVisible: activeFocus
                    enabled: root.editable

                    onActiveFocusChanged: {
                        if (activeFocus)
                            root.openMenu()
                    }

                    onTextChanged: {
                        if (activeFocus) {
                            root.refreshMenu()
                            suggestionsPopup.open()
                        }
                    }

                    Keys.onPressed: (event) => root.handleInputKey(event)
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            cursorShape: Qt.IBeamCursor
            onClicked: root.focusAndOpenMenu()
        }
    }

    ToolButton {
        id: dropIndicator
        flat: true
        width: 28
        height: 24
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        focusPolicy: Qt.NoFocus
        icon.name: ""
        hoverable: root.editable

        IconWidget {
            anchors.centerIn: parent
            z: 1
            icon: "ic_fluent_chevron_down_20_regular"
            size: 14
            color: Theme.currentTheme.colors.textSecondaryColor
            rotation: suggestionsPopup.visible ? 180 : 0

            Behavior on rotation {
                NumberAnimation {
                    duration: Utils.animationSpeed
                    easing.type: Easing.OutQuint
                }
            }
        }

        onClicked: {
            let wasVisible = suggestionsPopup.visible
            root.inputControl.forceActiveFocus()
            if (wasVisible)
                suggestionsPopup.close()
            else
                root.openMenu()
        }
    }

    Popup {
        id: suggestionsPopup
        x: 0
        y: root.height
        width: root.width
        implicitHeight: Math.min(filteredModel.contentHeight + 6, root.maximumMenuHeight)
        height: implicitHeight
        padding: 0
        focus: false
        closePolicy: Popup.CloseOnPressOutside

        ListView {
            id: filteredModel
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.bottomMargin: 4
            clip: true

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: ListViewDelegate {
                width: filteredModel.width
                text: root.itemText(modelData)

                onClicked: {
                    root.addItem(modelData)
                    root.inputControl.forceActiveFocus()
                }
            }
        }

        background: Rectangle {
            id: popupBackground
            radius: Theme.currentTheme.appearance.windowRadius
            color: Theme.currentTheme.colors.backgroundAcrylicColor
            border.color: Theme.currentTheme.colors.controlBorderColor

            layer.enabled: true
            layer.effect: Shadow {
                style: "flyout"
                source: popupBackground
            }
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    target: suggestionsPopup
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 70
                    easing.type: Easing.InOutQuart
                }
                NumberAnimation {
                    target: suggestionsPopup
                    property: "height"
                    from: 46
                    to: suggestionsPopup.implicitHeight
                    duration: Utils.animationSpeedMiddle
                    easing.type: Easing.OutQuint
                }
            }
        }

        exit: Transition {
            NumberAnimation {
                target: suggestionsPopup
                property: "opacity"
                from: 1
                to: 0
                duration: 150
                easing.type: Easing.InOutQuart
            }
        }
    }

    states: [
        State {
            name: "disabled"
            when: !root.enabled
            PropertyChanges {
                target: root
                opacity: 0.4
            }
        }
    ]
}
