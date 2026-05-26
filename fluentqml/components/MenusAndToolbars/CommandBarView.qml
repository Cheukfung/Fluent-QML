import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import "../../themes"
import "../../components"

Frame {
    id: root

    default property alias commands: bar.contentData
    property alias hiddenActions: bar.hiddenActions
    property alias commandSpacing: bar.commandSpacing
    property alias toolButtonStyle: bar.toolButtonStyle
    property alias buttonTight: bar.buttonTight
    property alias iconSize: bar.iconSize
    property alias bar: bar
    readonly property real preferredBarWidth: bar.suitableWidth()

    padding: 6
    implicitWidth: preferredBarWidth + leftPadding + rightPadding
    implicitHeight: bar.implicitHeight + topPadding + bottomPadding
    radius: 8
    color: Theme.currentTheme.colors.backgroundAcrylicColor
    borderColor: Theme.currentTheme.colors.flyoutBorderColor
    hoverable: false

    function suitableWidth() {
        return preferredBarWidth + leftPadding + rightPadding
    }

    function resizeToSuitableWidth() {
        width = suitableWidth()
    }

    CommandBar {
        id: bar
        width: root.preferredBarWidth
        anchors.centerIn: parent
        buttonTight: true
        iconSize: 14
        commandSpacing: 2
    }
}
