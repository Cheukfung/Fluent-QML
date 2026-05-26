import QtQuick 2.15
import QtQuick.Controls.Basic 2.15 as T
import "../../components"
import "../../themes"

T.MenuBar {
    id: menuBar
    padding: 4
    implicitWidth: contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : 0
    implicitHeight: contentItem ? contentItem.implicitHeight + topPadding + bottomPadding : 40

    delegate: T.MenuBarItem {
        id: menuBarItem
        focusPolicy: Qt.StrongFocus  // to get keyboard focus

        // accessibility
        FocusIndicator {
            control: parent
        }

        padding: 6
        topPadding: 5
        bottomPadding: 7

        contentItem: Text {
            id: text
            anchors.centerIn: parent
            typography: Typography.Body
            horizontalAlignment: Text.AlignHCenter
            text: menuBarItem.text
        }

        background: Rectangle {
            id: background
            implicitHeight: 32
            color: Theme.currentTheme.colors.subtleSecondaryColor
            radius: Theme.currentTheme.appearance.buttonRadius

            Behavior on color { ColorAnimation { duration: Utils.appearanceSpeed; easing.type: Easing.OutQuart } }
            opacity: !hovered ? 0 : 1
        }
    }

    background: Item {}
}
