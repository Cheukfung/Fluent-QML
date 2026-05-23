import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 2.15
import "../../themes"
import "../../components"

ToolButton {
    id: root
    default property alias contentData: splitMenu.contentData
    property alias menu: splitMenu
    property int menuButtonWidth: 28

    implicitWidth: Math.max(64, implicitHeight + menuButtonWidth)
    contentRightInset: menuButtonWidth

    Menu {
        id: splitMenu
    }

    Rectangle {
        width: Theme.currentTheme.appearance.borderWidth
        height: parent.height - 10
        anchors.right: parent.right
        anchors.rightMargin: root.menuButtonWidth
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.currentTheme.colors.controlBorderColor
        opacity: root.enabled && !root.flat ? 1 : 0
    }

    IconWidget {
        anchors.right: parent.right
        anchors.rightMargin: (root.menuButtonWidth - width) / 2
        anchors.verticalCenter: parent.verticalCenter
        icon: "ic_fluent_chevron_down_20_filled"
        size: 12
        color: root.enabled
            ? (root.highlighted && !root.flat
                ? Theme.currentTheme.colors.textOnAccentColor
                : Theme.currentTheme.colors.textSecondaryColor)
            : Theme.currentTheme.colors.disabledColor
    }

    MouseArea {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.menuButtonWidth
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (splitMenu.count > 0) {
                splitMenu.open()
            }
        }
    }
}
