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

    background: Item {
        Rectangle {
            id: indicator
            x: root.indicatorX + root.indicatorWidth / 2 - width / 2
            y: parent.height - height
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
