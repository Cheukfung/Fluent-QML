import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 2.15
import "../BasicInput" as BasicInput
import "../../themes"
import "../../components"

ItemDelegate {
    id: delegate
    width: ListView.view ? ListView.view.width : 240
    highlighted: row.path === control.currentPath
    focusPolicy: Qt.StrongFocus

    readonly property var control: ListView.view.parent
    readonly property var row: modelData
    readonly property var itemData: row.item
    readonly property string displayIcon: control.itemIcon(itemData, row.hasChildren)
    readonly property bool rowVisible: control.isRowVisible(row.path)
    readonly property bool rowExpanded: {
        control._revision
        return control.isExpanded(itemData, row.path)
    }

    FocusIndicator {
        control: parent
    }

    height: rowVisible ? control.rowHeight : 0
    visible: height > 0
    opacity: rowVisible ? 1 : 0
    enabled: rowVisible
    clip: true

    contentItem: Item { }

    Behavior on height {
        NumberAnimation {
            duration: Utils.animationSpeed
            easing.type: Easing.OutQuint
        }
    }

    background: Rectangle {
        anchors.fill: parent
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
        radius: Theme.currentTheme.appearance.buttonRadius
        color: delegate.pressed
            ? Theme.currentTheme.colors.subtleTertiaryColor
            : (delegate.highlighted || delegate.hovered)
                ? Theme.currentTheme.colors.subtleSecondaryColor
                : Theme.currentTheme.colors.subtleColor

        Indicator {
            currentItemHeight: delegate.height
            visible: delegate.highlighted
        }

        Behavior on color {
            ColorAnimation {
                duration: Utils.appearanceSpeed
                easing.type: Easing.InOutQuart
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: control.leftPadding + 8 + row.depth * control.indent
        anchors.rightMargin: control.rightPadding + 10
        spacing: 8

        Item {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            visible: row.hasChildren

            Icon {
                anchors.centerIn: parent
                size: 14
                color: Theme.currentTheme.colors.textColor
                name: "ic_fluent_chevron_down_20_regular"
                rotation: rowExpanded ? 0 : -90

                Behavior on rotation {
                    NumberAnimation {
                        duration: Utils.animationSpeed
                        easing.type: Easing.OutQuint
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: control.activateRow(index)
            }
        }

        Item {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            visible: !row.hasChildren
        }

        BasicInput.CheckBox {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            visible: control.checkable
            checked: itemData[control.checkedRole] === true
            text: ""
            onClicked: control.setRowChecked(index, checked)
        }

        Icon {
            Layout.preferredWidth: visible ? 18 : 0
            Layout.preferredHeight: 18
            size: 18
            visible: displayIcon.length > 0
            color: Theme.currentTheme.colors.textSecondaryColor
            name: displayIcon
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            typography: Typography.Body
            elide: Text.ElideRight
            maximumLineCount: 1
            text: control.itemText(itemData)
        }
    }

    onClicked: control.selectRow(index)
    Keys.onSpacePressed: {
        if (control.checkable) {
            control.setItemChecked(itemData, itemData[control.checkedRole] !== true)
        } else if (row.hasChildren) {
            control.activateRow(index)
        }
    }
    Keys.onReturnPressed: control.selectRow(index)
}
