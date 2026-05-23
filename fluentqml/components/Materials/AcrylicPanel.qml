import QtQuick 2.15
import FluentQML 1.0
import "../../themes"

AcrylicItem {
    id: root

    property bool autoRefresh: true
    property int refreshDelay: 0
    property color lightTintColor: Qt.rgba(1, 1, 1, 180 / 255)
    property color darkTintColor: Qt.rgba(32 / 255, 32 / 255, 32 / 255, 200 / 255)
    property color lightLuminosityColor: Qt.rgba(1, 1, 1, 0)
    property color darkLuminosityColor: Qt.rgba(0, 0, 0, 0)

    blurRadius: 30
    maxBlurSize: 450
    radius: Theme.currentTheme.appearance.windowRadius
    tintColor: Theme.isDark() ? darkTintColor : lightTintColor
    luminosityColor: Theme.isDark() ? darkLuminosityColor : lightLuminosityColor
    noiseOpacity: 0.03
    borderWidth: Theme.currentTheme.appearance.borderWidth
    borderColor: Theme.currentTheme.colors.flyoutBorderColor

    function requestRefresh() {
        if (!autoRefresh || !visible || width <= 0 || height <= 0) {
            return
        }
        refreshTimer.restart()
    }

    Component.onCompleted: Qt.callLater(requestRefresh)
    onVisibleChanged: Qt.callLater(requestRefresh)
    onWidthChanged: requestRefresh()
    onHeightChanged: requestRefresh()
    onBlurRadiusChanged: requestRefresh()
    onMaxBlurSizeChanged: requestRefresh()

    Connections {
        target: Theme
        function onCurrentThemeChanged() {
            root.requestRefresh()
        }
    }

    Timer {
        id: refreshTimer
        interval: root.refreshDelay
        repeat: false
        onTriggered: root.refresh()
    }
}
