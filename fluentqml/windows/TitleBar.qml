import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts
import QtQuick.Window 2.3
import "../themes"
import "../components"
import "../windows"

Item {
    id: root
    property int titleBarHeight: Theme.currentTheme.appearance.dialogTitleBarHeight
    property alias title: titleLabel.text
    property alias icon: iconLabel.source
    property alias backgroundColor: rectBk.color

    // 自定义属性
    property bool titleEnabled: true
    property alias iconEnabled: iconLabel.visible
    property bool minimizeEnabled: true
    property bool maximizeEnabled: true
    property bool closeEnabled: true
    // Keep macOS detection resilient across Qt variants.
    property bool isMacOS: Qt.platform.os === "osx" || Qt.platform.os === "macos" || Qt.platform.os === "darwin"
    property bool useNativeMacControls: false
    property bool showMacCustomControls: root.isMacOS && !root.useNativeMacControls
    property int macControlSize: 12
    property int macControlSpacing: 8
    property int macControlLeftMargin: 20
    property int macControlRightMargin: 20
    property int macDragGap: 12
    // Reserve a small leading no-drag zone for overlay actions (e.g. NavigationView back button).
    property int macLeadingInteractiveWidth: 40
    property int macTrailingInteractiveWidth: 12
    property bool macTrafficLightsRightAligned: root.isMacOS
        && root.window
        && root.window.macTrafficLightsRightAligned === true
    // Align custom title content with native traffic lights on macOS.
    property real macNativeContentVerticalOffset: root.isMacOS && root.useNativeMacControls
        ? ((root.window && root.window.macNativeContentVerticalOffset !== undefined)
            ? root.window.macNativeContentVerticalOffset
            : -2)
        : 0
    property int macNativeControlCount: root.isMacOS && root.useNativeMacControls ? 3 : 0
    property int macVisibleControlCount: root.showMacCustomControls
        ? (closeVisible ? 1 : 0) + (minimizeVisible ? 1 : 0) + (maximizeVisible ? 1 : 0)
        : 0
    property int macControlOccupyCount: macVisibleControlCount > 0 ? macVisibleControlCount : macNativeControlCount
    property int macControlGroupWidth: macControlOccupyCount > 0
        ? (macControlOccupyCount * macControlSize) + ((macControlOccupyCount - 1) * macControlSpacing)
        : 0
    property int macLeadingInset: root.isMacOS && macControlOccupyCount > 0
        ? root.macControlLeftMargin + (macControlOccupyCount * root.macControlSize) + ((macControlOccupyCount - 1) * root.macControlSpacing) + root.macDragGap
        : 0
    property int macTrailingInset: root.isMacOS && macControlOccupyCount > 0
        ? root.macControlRightMargin + root.macControlGroupWidth + root.macDragGap
        : 0
    property bool macControlsHovered: root.showMacCustomControls && (
        (macCloseBtn.visible && (macCloseBtn.localHovered || macCloseBtn.localPressed)) ||
        (macMinimizeBtn.visible && (macMinimizeBtn.localHovered || macMinimizeBtn.localPressed)) ||
        (macMaximizeBtn.visible && (macMaximizeBtn.localHovered || macMaximizeBtn.localPressed)) ||
        (macCloseBtnRight.visible && (macCloseBtnRight.localHovered || macCloseBtnRight.localPressed)) ||
        (macMinimizeBtnRight.visible && (macMinimizeBtnRight.localHovered || macMinimizeBtnRight.localPressed)) ||
        (macMaximizeBtnRight.visible && (macMaximizeBtnRight.localHovered || macMaximizeBtnRight.localPressed))
    )

    property bool minimizeVisible: true
    property bool maximizeVisible: true
    property bool closeVisible: true

    // area
    default property alias content: contentItem.data
    property alias contentHost: contentItem
    property alias centerContent: centerContentItem.data
    property alias centerContentHost: centerContentItem


    height: titleBarHeight
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    clip: true
    z: 999

    implicitWidth: 200

    property var window: null
    function toggleMaximized() {
        if (!maximizeEnabled) {
            return
        }
        WindowManager.maximizeWindow(window)
    }

    // Sync maximize button visual state with native non-client interactions on Windows.
    Connections {
        target: (Qt.platform.os === "windows" && typeof WinEventManager !== "undefined") ? WinEventManager : null
        function onMaximizeBtnHovered(hwnd) {
            if (!window || WinEventManager.getWindowId(window) !== hwnd) {
                return
            }
            maximizeBtn.nativeHovered = true
        }
        function onMaximizeBtnLeave(hwnd) {
            if (!window || WinEventManager.getWindowId(window) !== hwnd) {
                return
            }
            maximizeBtn.nativeHovered = false
            maximizeBtn.nativePressed = false
        }
        function onMaximizeBtnPressed(hwnd) {
            if (!window || WinEventManager.getWindowId(window) !== hwnd) {
                return
            }
            maximizeBtn.nativePressed = true
        }
        function onMaximizeBtnReleased(hwnd) {
            if (!window || WinEventManager.getWindowId(window) !== hwnd) {
                return
            }
            maximizeBtn.nativePressed = false
            maximizeBtn.nativeHovered = false
        }
    }

    Rectangle{
        id:rectBk
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            enabled: Qt.platform.os !== "windows"
            anchors.fill: parent
            anchors.leftMargin: root.isMacOS
                ? (root.macTrafficLightsRightAligned ? Utils.windowDragArea : root.macLeadingInset + root.macLeadingInteractiveWidth)
                : 48
            anchors.rightMargin: root.isMacOS && root.macTrafficLightsRightAligned
                ? root.macTrailingInset + root.macTrailingInteractiveWidth
                : Utils.windowDragArea
            anchors.margins: Utils.windowDragArea
            propagateComposedEvents: true
            acceptedButtons: Qt.LeftButton

            onPressed: {
                if (Qt.platform.os === "windows") {
                    return
                }
                if (window.isMaximized || window.isFullScreen || window.visibility === Window.Maximized) {
                    return
                }
                window.startSystemMove()
            }
            onDoubleClicked: {
                if (Qt.platform.os === "windows") {
                    return
                }
                toggleMaximized()
            }
        }
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.macNativeContentVerticalOffset
        height: parent.height
        anchors.margins: 0
        spacing: root.isMacOS ? (root.showMacCustomControls ? 12 : 0) : 48

        // macOS traffic-light controls stay on the left side by default.
        Row {
            id: macWindowControls
            visible: root.showMacCustomControls && !root.macTrafficLightsRightAligned
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: root.macControlLeftMargin
            spacing: root.macControlSpacing

            CtrlBtn {
                id: macCloseBtn
                mode: 2
                width: root.macControlSize
                height: root.macControlSize
                enabled: root.closeEnabled
                visible: root.closeVisible
                macGroupHovered: root.macControlsHovered
            }
            CtrlBtn {
                id: macMinimizeBtn
                mode: 1
                width: root.macControlSize
                height: root.macControlSize
                enabled: root.minimizeEnabled
                visible: root.minimizeVisible
                macGroupHovered: root.macControlsHovered
            }
            CtrlBtn {
                id: macMaximizeBtn
                mode: 0
                width: root.macControlSize
                height: root.macControlSize
                enabled: root.maximizeEnabled
                visible: root.maximizeVisible
                macGroupHovered: root.macControlsHovered

            }
        }
        // 窗口标题 / Window Title

        RowLayout {
            id: titleRow
            visible: root.titleEnabled
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: root.isMacOS
                ? (root.useNativeMacControls && !root.macTrafficLightsRightAligned ? root.macLeadingInset : 0)
                : 16
            Layout.rightMargin: root.isMacOS && root.useNativeMacControls && root.macTrafficLightsRightAligned
                ? root.macTrailingInset
                : 0
            spacing: 16

            //图标
            IconWidget {
                id: iconLabel
                size: 16
                Layout.alignment: Qt.AlignVCenter
                // anchors.verticalCenter: parent.verticalCenter
                visible: icon || source
            }

            //标题
            Text {
                id: titleLabel
                Layout.alignment: Qt.AlignVCenter
                // anchors.verticalCenter:  parent.verticalCenter

                typography: Typography.Caption
                text: qsTr("Fluent TitleBar")
            }
        }

        Item {
            // custom
            id: contentItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: root.isMacOS && root.useNativeMacControls && root.macTrafficLightsRightAligned
                ? root.macTrailingInset
                : 0
            clip: true
        }

        Row {
            id: macWindowControlsRight
            visible: root.showMacCustomControls && root.macTrafficLightsRightAligned
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: root.macControlRightMargin
            spacing: root.macControlSpacing

            CtrlBtn {
                id: macCloseBtnRight
                mode: 2
                width: root.macControlSize
                height: root.macControlSize
                enabled: root.closeEnabled
                visible: root.closeVisible
                macGroupHovered: root.macControlsHovered
            }
            CtrlBtn {
                id: macMinimizeBtnRight
                mode: 1
                width: root.macControlSize
                height: root.macControlSize
                enabled: root.minimizeEnabled
                visible: root.minimizeVisible
                macGroupHovered: root.macControlsHovered
            }
            CtrlBtn {
                id: macMaximizeBtnRight
                mode: 0
                width: root.macControlSize
                height: root.macControlSize
                enabled: root.maximizeEnabled
                visible: root.maximizeVisible
                macGroupHovered: root.macControlsHovered
            }
        }

        // 窗口按钮 / Window Controls
        Row {
            id: windowControls
            visible: !root.isMacOS
            width: implicitWidth
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight
            spacing: 0
            CtrlBtn {
                id: minimizeBtn
                mode: 1
                enabled: root.minimizeEnabled
                visible: root.minimizeVisible
            }
            CtrlBtn {
                id: maximizeBtn
                mode: 0
                enabled: root.maximizeEnabled
                visible: root.maximizeVisible

            }
            CtrlBtn {
                id: closeBtn
                mode: 2
                enabled: root.closeEnabled
                visible: root.closeVisible
            }
        }
    }

    Item {
        id: centerContentItem
        anchors.fill: parent
        clip: true
        z: 3
    }
}
