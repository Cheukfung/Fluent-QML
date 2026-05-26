import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 2.15
import "../../themes"
import "../../components"

PageIndicator {
    id: control

    property bool carel: false

    spacing: 0
    implicitHeight: 24
    leftPadding: carel ? 24 : 0
    rightPadding: carel ? 24 : 0

    Item {
        width: carel ? 24 : 0
        height: 24
        visible: carel && control.currentIndex > 0
        anchors.left: parent.left
        enabled: control.enabled && control.interactive

        Icon {
            anchors.centerIn: parent
            name: "ic_fluent_caret_left_20_filled"
            size: leftTapHandler.pressed ? 14 : 16
            color: parent.enabled && leftHoverHandler.hovered
                ? Theme.currentTheme.colors.textSecondaryColor
                : Theme.currentTheme.colors.controlStrongColor
            opacity: parent.enabled ? 1 : 0.35
        }

        HoverHandler {
            id: leftHoverHandler
        }

        TapHandler {
            id: leftTapHandler
            enabled: parent.enabled
            onTapped: control.currentIndex = Math.max(0, control.currentIndex - 1)
        }
    }

    Item {
        width: carel ? 24 : 0
        height: 24
        visible: carel && control.currentIndex < control.count - 1
        anchors.right: parent.right
        enabled: control.enabled && control.interactive

        Icon {
            anchors.centerIn: parent
            name: "ic_fluent_caret_right_20_filled"
            size: rightTapHandler.pressed ? 14 : 16
            color: parent.enabled && rightHoverHandler.hovered
                ? Theme.currentTheme.colors.textSecondaryColor
                : Theme.currentTheme.colors.controlStrongColor
            opacity: parent.enabled ? 1 : 0.35
        }

        HoverHandler {
            id: rightHoverHandler
        }

        TapHandler {
            id: rightTapHandler
            enabled: parent.enabled
            onTapped: control.currentIndex = Math.min(control.count - 1, control.currentIndex + 1)
        }
    }

    delegate: Item {
        id: btn
        implicitWidth: 12
        implicitHeight: 12
        anchors.verticalCenter: parent.verticalCenter

        required property int index

        property int size: {
            if (pressed) {
                return 4
            }
            if (hoverHandler.hovered) {
                return 6
            }
            if (index === control.currentIndex) {
                return 6
            }
            return 4
        }

        Rectangle {
            anchors.centerIn: parent
            width: btn.size
            height: btn.size
            radius: width / 2
            color: hoverHandler.hovered
                ? Theme.currentTheme.colors.textSecondaryColor
                : Theme.currentTheme.colors.controlStrongColor
        }

        opacity: control.enabled ? 1 : 0.5

        HoverHandler {
            id: hoverHandler
        }

        TapHandler {
            enabled: control.enabled && control.interactive
            onTapped: control.currentIndex = btn.index
        }
    }
}
