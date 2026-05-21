import QtQuick 2.15
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts 2.15
import "../../themes"
import "../../components"


Basic.TableViewDelegate {
    id: delegate
    implicitWidth: Math.max(120, contents.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(38, contents.implicitHeight + topPadding + bottomPadding)
    highlighted: selected || currentCell
    focusPolicy: Qt.StrongFocus
    leftPadding: 16
    rightPadding: 16
    topPadding: 0
    bottomPadding: 0

    property bool alternate: false
    property bool firstColumn: false
    property bool lastColumn: false
    property bool currentCell: false
    property bool rowHovered: false
    property bool rowPressed: false
    property bool showGridLines: false
    property bool showRowSeparator: true
    property bool showSelectionIndicator: true
    property color gridLineColor: Theme.currentTheme.colors.dividerBorderColor
    readonly property bool dark: Theme.currentTheme.isDark
    readonly property real rowBackgroundAlpha: {
        if (!selected) {
            if (rowPressed) {
                return dark ? 9 / 255 : 6 / 255
            }
            if (rowHovered) {
                return 12 / 255
            }
            if (alternate) {
                return 5 / 255
            }
            return 0
        }

        if (rowPressed) {
            return dark ? 15 / 255 : 9 / 255
        }
        if (rowHovered) {
            return 25 / 255
        }
        return 17 / 255
    }
    readonly property color rowBackgroundColor: dark
        ? Qt.rgba(1, 1, 1, rowBackgroundAlpha)
        : Qt.rgba(0, 0, 0, rowBackgroundAlpha)

    // accessibility
    FocusIndicator {
        control: delegate
    }

    property alias leftArea: leftArea.data
    property alias middleArea: middleArea.data
    property alias rightArea: rightArea.data

    contentItem: RowLayout {
        id: contents
        spacing: 8

        Row {
            id: leftArea
            // CheckBox {
            //     id: checkBox
            //     implicitWidth: height * 1
            //     Layout.fillHeight: true
            //     checked: false
            //     visible: tableCell.column === 0
            // }
        }

        ColumnLayout {
            id: middleArea
            Layout.fillHeight: true
        }

        RowLayout {
            id: rightArea
            spacing: 16
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    background: Item {
        id: itemBg
        anchors.fill: parent
        clip: true

        Rectangle {
            id: rowBackground
            readonly property int backgroundRadius: 5

            x: firstColumn ? 4 : (lastColumn ? -backgroundRadius - 1 : -1)
            y: 2
            width: firstColumn
                ? parent.width - 4 + backgroundRadius + 1
                : (lastColumn
                    ? parent.width + backgroundRadius + 1 - 4
                    : parent.width + 2)
            height: parent.height - 4
            radius: (firstColumn || lastColumn) ? backgroundRadius : 0
            color: delegate.rowBackgroundColor

            Behavior on color { ColorAnimation { duration: Utils.appearanceSpeed; easing.type:Easing.InOutQuart } }
        }

        // 选择指示器
        Rectangle {
            width: 3
            height: Math.round(parent.height * (delegate.rowPressed ? 0.3 : 0.486))
            radius: 1.5
            color: Theme.currentTheme.colors.primaryColor
            visible: selected && delegate.showSelectionIndicator
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: delegate.gridLineColor
            visible: delegate.showRowSeparator && !highlighted && !rowHovered
        }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 1
            color: delegate.gridLineColor
            visible: delegate.showGridLines && !lastColumn
        }
    }
}
