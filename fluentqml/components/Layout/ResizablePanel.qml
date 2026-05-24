import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import "../../themes"

SplitView {
    id: root

    property real handleThickness: 8
    property real handleLineThickness: 1
    property color handleColor: Theme.currentTheme.colors.controlBorderColor
    property color handleHoverColor: Theme.currentTheme.colors.controlStrongColor
    property color handlePressedColor: Theme.currentTheme.colors.primaryColor
    property color handleBackgroundColor: "transparent"

    orientation: Qt.Horizontal
    clip: true

    handle: Rectangle {
        implicitWidth: root.orientation === Qt.Horizontal ? root.handleThickness : 1
        implicitHeight: root.orientation === Qt.Vertical ? root.handleThickness : 1
        color: root.handleBackgroundColor

        Rectangle {
            anchors.centerIn: parent
            width: root.orientation === Qt.Horizontal
                ? root.handleLineThickness
                : Math.max(24, parent.width - root.handleThickness * 2)
            height: root.orientation === Qt.Horizontal
                ? Math.max(24, parent.height - root.handleThickness * 2)
                : root.handleLineThickness
            radius: root.handleLineThickness / 2
            color: SplitHandle.pressed
                ? root.handlePressedColor
                : SplitHandle.hovered ? root.handleHoverColor : root.handleColor

            Behavior on color {
                ColorAnimation {
                    duration: Utils.appearanceSpeed
                    easing.type: Easing.OutQuart
                }
            }
        }
    }
}
