import QtQuick 2.15
import "../../themes"

Item {
    id: root

    implicitWidth: 9
    implicitHeight: 34

    Rectangle {
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.currentTheme.colors.dividerBorderColor
        opacity: 0.55
    }
}
