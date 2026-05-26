import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../../components"
import "../../themes"

TabBar {
    id: root
    implicitWidth: contentWidth
    implicitHeight: 32

    readonly property Item selectedItem: currentIndex >= 0 ? itemAt(currentIndex) : null
    readonly property real indicatorX: selectedItem ? selectedItem.mapToItem(root, 0, 0).x : 0
    readonly property real indicatorWidth: selectedItem ? selectedItem.width : 0

    background: Rectangle {
        border.width: Theme.currentTheme.appearance.borderWidth  // 边框宽度 / Border Width
        border.color: Theme.currentTheme.isDark
            ? Qt.rgba(1, 1, 1, 0.0605)
            : Qt.rgba(0, 0, 0, 0.0578)
        radius: 6
        color: Theme.currentTheme.isDark
            ? Qt.rgba(1, 1, 1, 0.0419)
            : Qt.rgba(0, 0, 0, 0.0241)

        Rectangle {
            id: selectedBackground
            x: root.indicatorX + 1
            y: 1
            width: Math.max(0, root.indicatorWidth - 2)
            height: parent.height - 2
            radius: 5
            color: Theme.currentTheme.isDark
                ? Qt.rgba(1, 1, 1, 0.0605)
                : Qt.rgba(1, 1, 1, 0.702)
            border.width: Theme.currentTheme.appearance.borderWidth
            border.color: Theme.currentTheme.isDark
                ? Qt.rgba(1, 1, 1, 0.0824)
                : Qt.rgba(0, 0, 0, 0.0745)
            visible: root.selectedItem !== null

            Behavior on x {
                NumberAnimation {
                    duration: Utils.animationSpeedMiddle
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: Utils.animationSpeedMiddle
                    easing.type: Easing.OutQuint
                }
            }
        }

        Rectangle {
            id: indicator
            x: root.indicatorX + root.indicatorWidth / 2 - width / 2
            y: parent.height - height - 1
            width: 16
            height: 3
            radius: 1.5
            color: Theme.currentTheme.colors.primaryColor
            visible: root.selectedItem !== null

            Behavior on x {
                NumberAnimation {
                    duration: Utils.animationSpeedMiddle
                    easing.type: Easing.OutQuint
                }
            }
        }
    }
}
