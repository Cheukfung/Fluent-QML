import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../components"
import "../../themes"


Item {
    id: navigationBar
    // implicitWidth: collapsed ? 40 : expandWidth
    height: parent.height

    property bool collapsed: false
    property var navigationItems: [
        // {title: "Title", page: "path/to/page.qml", icon: undefined}
    ]
    // Keep macOS detection resilient across Qt variants.
    property bool isMacOS: Qt.platform.os === "osx" || Qt.platform.os === "macos" || Qt.platform.os === "darwin"
    property bool closeButtonVisible: true
    property bool minimizeButtonVisible: true
    property bool maximizeButtonVisible: true
    property bool useNativeMacControls: false
    property var window: null
    property int macControlSize: 12
    property int macControlSpacing: 8
    property int macControlLeftMargin: 20
    property int macControlRightMargin: 20
    property int macDragGap: 12
    property int macNativeControlExtraInset: useNativeMacControls ? 18 : 0
    property int macNativeVisualInset: useNativeMacControls ? 8 : 0
    property int macTitleLeftMargin: 6
    property bool macTrafficLightsRightAligned: isMacOS
        && window
        && window.macTrafficLightsRightAligned === true
    property int titleBarHeight: window && window.titleBarHeight !== undefined
        ? window.titleBarHeight
        : Theme.currentTheme.appearance.windowTitleBarHeight
    property int macVisibleControlCount: isMacOS
        ? (useNativeMacControls
            ? 3
            : (closeButtonVisible ? 1 : 0) + (minimizeButtonVisible ? 1 : 0) + (maximizeButtonVisible ? 1 : 0))
        : 0
    property int macTitleSafeInset: isMacOS && macVisibleControlCount > 0
        ? macControlLeftMargin + (macVisibleControlCount * macControlSize) + ((macVisibleControlCount - 1) * macControlSpacing) + macDragGap + macNativeControlExtraInset
        : 0
    property int macTitleTrailingSafeInset: isMacOS && macVisibleControlCount > 0
        ? macControlRightMargin + (macVisibleControlCount * macControlSize) + ((macVisibleControlCount - 1) * macControlSpacing) + macDragGap
        : 0

    // property int currentSubIndex: -1
    property bool titleBarEnabled: true
    property int expandWidth: 0  // 0 或负值=动态宽度，正值=固定宽度
    property int minimumExpandWidth: 900
    
    // 动态宽度系统配置
    property int minNavbarWidth: 200  // 最小导航栏宽度
    property int maxNavbarWidth: 400  // 最大导航栏宽度
    property bool enableDragResize: false  // 是否启用拖拽调整(可与动态/固定模式共存)
    
    property int userResizedWidth: 0  // 用户拖拽后的宽度(内部使用，拖拽后自动设置)

    property alias windowTitle: titleLabel.text
    property alias windowIcon: iconLabel.source
    property int windowWidth: minimumExpandWidth
    property var stackView: parent.stackView

    property string currentPage: ""  // 当前页面的URL
    property string previousCurrentPage: ""
    property bool indicatorAnimating: false
    property bool indicatorOverlayVisible: false
    property bool indicatorSuppressHandoff: false
    property real indicatorAnimationX: 0
    property real indicatorAnimationY: 0
    property real indicatorAnimationWidth: 3
    property real indicatorAnimationHeight: 16
    property real indicatorPhase1Y: 0
    property real indicatorPhase1Height: 16
    property real indicatorPhase2Y: 0
    property real indicatorPhase2Height: 16
    property bool collapsedByAutoResize: false
    property int cachedOptimalWidth: 280  // 缓存的最优宽度

    function isNotOverMinimumWidth() {  // 判断窗口是否小于最小宽度
        return windowWidth < minimumExpandWidth;
    }

    onCurrentPageChanged: {
        startIndicatorAnimation(previousCurrentPage, currentPage)
        previousCurrentPage = currentPage
    }

    function stopIndicatorAnimation() {
        indicatorSuppressHandoff = true
        indicatorSlideAnimation.stop()
        indicatorSuppressHandoff = false
        indicatorHandoffTimer.stop()
        indicatorAnimating = false
        indicatorOverlayVisible = false
    }

    function findIndicatorRectInRepeater(repeater, page) {
        for (let i = 0; i < repeater.count; i++) {
            let item = repeater.itemAt(i)
            if (!item) continue

            if (typeof item.indicatorRectForPage === "function") {
                let itemRect = item.indicatorRectForPage(page)
                if (itemRect) return itemRect
            }

            if (item.subItemsRepeater && !item.collapsed) {
                for (let j = 0; j < item.subItemsRepeater.count; j++) {
                    let subItem = item.subItemsRepeater.itemAt(j)
                    if (subItem && typeof subItem.indicatorRectForPage === "function") {
                        let subItemRect = subItem.indicatorRectForPage(page)
                        if (subItemRect) return subItemRect
                    }
                }
            }
        }
        return null
    }

    function findIndicatorRect(page) {
        if (page === "") return null
        return findIndicatorRectInRepeater(topRepeater, page)
            || findIndicatorRectInRepeater(mainRepeater, page)
            || findIndicatorRectInRepeater(bottomRepeater, page)
    }

    function startIndicatorAnimation(previousPage, nextPage) {
        if (previousPage === "" || nextPage === "" || String(previousPage) === String(nextPage)) {
            stopIndicatorAnimation()
            return
        }

        let startRect = findIndicatorRect(previousPage)
        let endRect = findIndicatorRect(nextPage)
        if (!startRect || !endRect || Math.abs(startRect.x - endRect.x) >= 1) {
            stopIndicatorAnimation()
            return
        }

        let startY = startRect.y
        let endY = endRect.y
        let startHeight = startRect.height
        let endHeight = endRect.height
        let distance = Math.abs(endY - startY)
        let stretchedHeight = distance + (endY > startY ? endHeight : startHeight)

        indicatorSuppressHandoff = true
        indicatorSlideAnimation.stop()
        indicatorSuppressHandoff = false
        indicatorHandoffTimer.stop()
        indicatorAnimationX = endRect.x
        indicatorAnimationWidth = endRect.width
        indicatorAnimationY = startY
        indicatorAnimationHeight = startHeight

        if (endY > startY) {
            indicatorPhase1Y = startY
            indicatorPhase1Height = stretchedHeight
            indicatorPhase2Y = endY
            indicatorPhase2Height = endHeight
        } else {
            indicatorPhase1Y = endY
            indicatorPhase1Height = stretchedHeight
            indicatorPhase2Y = endY
            indicatorPhase2Height = endHeight
        }

        indicatorAnimating = true
        indicatorOverlayVisible = true
        indicatorSlideAnimation.start()
    }
    
    // 获取有效宽度(综合考虑拖拽、固定、动态三种模式)
    function getEffectiveWidth() {
        // 优先级 1: 用户拖拽的宽度(如果启用拖拽调整且用户已拖拽)
        if (enableDragResize && userResizedWidth > 0) {
            return userResizedWidth
        }
        
        // 优先级 2: 固定宽度(如果 expandWidth > 0)
        if (expandWidth > 0) {
            return expandWidth
        }
        
        // 优先级 3: 动态宽度(基于内容智能计算)
        return cachedOptimalWidth
    }
    
    // 计算所有导航项的最优宽度
    function calculateOptimalWidth() {
        let maxWidth = minNavbarWidth
        
        // 遍历顶部导航项
        for (let i = 0; i < topRepeater.count; i++) {
            let item = topRepeater.itemAt(i)
            if (item && item.itemData) {
                navigationTextMetrics.text = item.itemData.title || ""
                // icon(19) + spacing(16) + leftMargin(11) + padding(20) = 66
                // 如果有子项，额外加上展开按钮宽度
                let expandBtnWidth = (item.itemData.subItems && item.itemData.subItems.length > 0) ? 28 : 0
                let requiredWidth = navigationTextMetrics.width + 66 + expandBtnWidth
                maxWidth = Math.max(maxWidth, requiredWidth)
                
                // 如果有子项且当前项未折叠，计算子项宽度
                if (item.itemData.subItems && !item.collapsed) {
                    for (let j = 0; j < item.itemData.subItems.length; j++) {
                        navigationTextMetrics.text = item.itemData.subItems[j].title || ""
                        let subWidth = navigationTextMetrics.width + 82  // 66 + 16 (额外缩进)
                        maxWidth = Math.max(maxWidth, subWidth)
                    }
                }
            }
        }
        
        // 遍历中间导航项
        for (let i = 0; i < mainRepeater.count; i++) {
            let item = mainRepeater.itemAt(i)
            if (item && item.itemData) {
                navigationTextMetrics.text = item.itemData.title || ""
                let expandBtnWidth = (item.itemData.subItems && item.itemData.subItems.length > 0) ? 28 : 0
                let requiredWidth = navigationTextMetrics.width + 66 + expandBtnWidth
                maxWidth = Math.max(maxWidth, requiredWidth)
                
                if (item.itemData.subItems && !item.collapsed) {
                    for (let j = 0; j < item.itemData.subItems.length; j++) {
                        navigationTextMetrics.text = item.itemData.subItems[j].title || ""
                        let subWidth = navigationTextMetrics.width + 82
                        maxWidth = Math.max(maxWidth, subWidth)
                    }
                }
            }
        }
        
        // 遍历底部导航项
        for (let i = 0; i < bottomRepeater.count; i++) {
            let item = bottomRepeater.itemAt(i)
            if (item && item.itemData) {
                navigationTextMetrics.text = item.itemData.title || ""
                let expandBtnWidth = (item.itemData.subItems && item.itemData.subItems.length > 0) ? 28 : 0
                let requiredWidth = navigationTextMetrics.width + 66 + expandBtnWidth
                maxWidth = Math.max(maxWidth, requiredWidth)
                
                if (item.itemData.subItems && !item.collapsed) {
                    for (let j = 0; j < item.itemData.subItems.length; j++) {
                        navigationTextMetrics.text = item.itemData.subItems[j].title || ""
                        let subWidth = navigationTextMetrics.width + 82
                        maxWidth = Math.max(maxWidth, subWidth)
                    }
                }
            }
        }
        
        // 限制在最小/最大宽度之间，并对齐到 4px
        return Math.min(Math.ceil(Math.max(maxWidth, minNavbarWidth) / 4) * 4, maxNavbarWidth)
    }
    
    // 请求重新计算布局
    function requestLayoutUpdate() {
        if (expandWidth <= 0 && !collapsed) {  // 仅在动态宽度模式下计算
            Qt.callLater(function() {
                // 异步计算并更新缓存的最优宽度
                cachedOptimalWidth = calculateOptimalWidth()
            })
        }
    }
    
    // 组件完成时初始化缓存宽度
    Component.onCompleted: {
        if (expandWidth <= 0) {  // 仅在动态宽度模式下初始化
            Qt.callLater(function() {
                cachedOptimalWidth = calculateOptimalWidth()
            })
        }
    }
    
    // TextMetrics 用于计算文本宽度
    TextMetrics {
        id: navigationTextMetrics
        font.pixelSize: 14  // Typography.Body
        font.family: "Microsoft YaHei"
    }

    // 展开收缩动画 //
    width: collapsed ? 40 : getEffectiveWidth()
    implicitWidth: isNotOverMinimumWidth() ? 40 : collapsed ? 40 : getEffectiveWidth()

    Behavior on width {
        NumberAnimation {
            duration: Utils.animationSpeed
            easing.type: Easing.OutQuint
        }
    }
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Utils.animationSpeed
            easing.type: Easing.OutQuint
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: -5
        anchors.topMargin: 0
        radius: Theme.currentTheme.appearance.windowRadius
        color: Theme.currentTheme.colors.backgroundAcrylicColor
        border.color: Theme.currentTheme.colors.flyoutBorderColor
        z: -1
        visible: isNotOverMinimumWidth() && !collapsed

        Behavior on visible {
            NumberAnimation {
                duration: collapsed ? Utils.animationSpeed / 2 : 50
            }
        }

        layer.enabled: true
        layer.effect: Shadow {
            style: "flyout"
            source: background
        }
    }

    Row {
        id: title
        parent: navigationBar.window && navigationBar.window.titleBarHost
            ? navigationBar.window.titleBarHost
            : navigationBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: navigationBar.macTrafficLightsRightAligned
            ? navigationBar.macTitleLeftMargin
            : navigationBar.macTitleSafeInset + navigationBar.macNativeVisualInset
        anchors.rightMargin: navigationBar.macTrafficLightsRightAligned
            ? navigationBar.macTitleTrailingSafeInset
            : 0
        anchors.verticalCenter: parent.verticalCenter
        height: titleBarHeight
        spacing: 16
        visible: navigationBar.titleBarEnabled
        z: 2

        // 返回按钮
        ToolButton {
            flat: true
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "ic_fluent_arrow_left_20_regular"
            onClicked: navigationView.safePop()
            property int controlSize: Math.max(32, Math.min(40, title.height - 4))
            width: controlSize
            height: controlSize
            size: 16
            enabled: navigationView.lastPages.length > 0

            ToolTip {
                parent: parent
                delay: 500
                visible: parent.hovered
                text: qsTr("Back")
            }
        }

        //图标
        IconWidget {
            id: iconLabel
            size: 16
            anchors.verticalCenter: parent.verticalCenter
        }

        //标题
        Text {
            id: titleLabel
            anchors.verticalCenter:  parent.verticalCenter

            typography: Typography.Caption
            // text: title
        }
    }

    // 收起切换按钮
    ToolButton {
        id: collapseButton
        flat: true
        width: 40
        height: 38
        // icon.name: collapsed ? "ic_fluent_chevron_right_20_regular" : "ic_fluent_chevron_left_20_regular"
        icon.name: "ic_fluent_navigation_20_regular"
        size: 19
        y: -2

        onClicked: {
            collapsed = !collapsed
            collapsedByAutoResize = false
        }

        ToolTip {
            parent: parent
            delay: 500
            visible: parent.hovered && !parent.pressed
            text: collapsed ? qsTr("Open Navigation") : qsTr("Close Navigation")
      }
    }

    // 数据过滤逻辑
    function getTopItems() {
        return navigationItems.filter(function(item) {
            return item.position === Position.Top;
        });
    }
    
    function getMiddleItems() {
        return navigationItems.filter(function(item) {
            return item.position === undefined || item.position === null || item.position === Position.None || item.position === Position.Center;
        });
    }
    
    function getBottomItems() {
        return navigationItems.filter(function(item) {
            return item.position === Position.Bottom;
        });
    }


    // 置顶导航项（固定在顶部，支持滚动）
    Flickable {
        id: topFlickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 38
        // 置顶区域最大高度：导航栏可用高度的 20%
        height: getTopItems().length > 0 ? Math.min(topNavigationColumn.implicitHeight, (parent.height - 40) * 0.2) : 0
        contentWidth: parent.width
        contentHeight: topNavigationColumn.implicitHeight
        clip: true
        visible: getTopItems().length > 0

        Column {
            id: topNavigationColumn
            width: topFlickable.width
            topPadding: 2
            spacing: 2

            Repeater {
                id: topRepeater
                model: navigationBar.getTopItems()
                delegate: NavigationItem {
                    id: topItem
                    itemData: modelData
                    currentPage: navigationBar.stackView

                    // 子菜单重置
                    Connections {
                        target: navigationBar
                        function onCollapsedChanged() {
                            if (!navigationBar.collapsed) {
                                return
                            }
                            topItem.collapsed = navigationBar.collapsed
                        }
                    }
                }
            }
        }

    }

    // Top Separator
    Rectangle {
        id: topSeparator
        anchors.top: topFlickable.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        z: 10
        color: Theme.currentTheme.colors.dividerBorderColor
        visible: navigationBar.getTopItems().length > 0
    }

    // 中间可滚动导航区域
    Flickable {
        id: flickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: topSeparator.visible ? topSeparator.bottom : topFlickable.bottom
        anchors.topMargin: topSeparator.visible ? 4 : 0
        anchors.bottom: bottomSeparator.visible ? bottomSeparator.top : bottomFlickable.top
        anchors.bottomMargin: bottomSeparator.visible ? 4 : 0
        contentWidth: parent.width
        contentHeight: navigationColumn.implicitHeight
        clip: true

        Column {
            id: navigationColumn
            width: flickable.width
            spacing: 2

            Repeater {
                id: mainRepeater
                model: navigationBar.getMiddleItems()
                delegate: NavigationItem {
                    id: item
                    itemData: modelData
                    currentPage: navigationBar.stackView

                    // 子菜单重置
                    Connections {
                        target: navigationBar
                        function onCollapsedChanged() {
                            if (!navigationBar.collapsed) {
                                return
                            }
                            item.collapsed = navigationBar.collapsed
                        }
                    }
                }
            }
        }

    }

    // Bottom Separator
    Rectangle {
        id: bottomSeparator
        anchors.bottom: bottomFlickable.top
        anchors.bottomMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        z: 10
        color: Theme.currentTheme.colors.dividerBorderColor
        visible: navigationBar.getBottomItems().length > 0
    }

    // 底部导航项（固定在底部，支持滚动）
    Flickable {
        id: bottomFlickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -2
        // 底部区域最大高度：导航栏可用高度的 20%
        height: getBottomItems().length > 0 ? Math.min(bottomNavigationColumn.implicitHeight, (parent.height - 40) * 0.2) : 0
        contentWidth: parent.width
        contentHeight: bottomNavigationColumn.implicitHeight
        clip: true
        visible: getBottomItems().length > 0

        // 默认滚动到底部
        Component.onCompleted: {
            if (contentHeight > height) {
                contentY = contentHeight - height;
            }
        }

        // 内容高度变化时保持在底部
        onContentHeightChanged: {
            if (contentHeight > height) {
                contentY = contentHeight - height;
            }
        }

        Column {
            id: bottomNavigationColumn
            width: bottomFlickable.width
            spacing: 2

            Repeater {
                id: bottomRepeater
                model: navigationBar.getBottomItems()
                delegate: NavigationItem {
                    id: bottomItem
                    itemData: modelData
                    currentPage: navigationBar.stackView

                    // 子菜单重置
                    Connections {
                        target: navigationBar
                        function onCollapsedChanged() {
                            if (!navigationBar.collapsed) {
                                return
                            }
                            bottomItem.collapsed = navigationBar.collapsed
                        }
                    }
                }
            }
        }

    }

    Rectangle {
        id: slidingIndicator
        x: navigationBar.indicatorAnimationX
        y: navigationBar.indicatorAnimationY
        width: navigationBar.indicatorAnimationWidth
        height: navigationBar.indicatorAnimationHeight
        radius: 10
        color: Theme.currentTheme.colors.primaryColor
        visible: navigationBar.indicatorOverlayVisible
        z: 999
    }

    SequentialAnimation {
        id: indicatorSlideAnimation

        ParallelAnimation {
            NumberAnimation {
                target: navigationBar
                property: "indicatorAnimationY"
                to: navigationBar.indicatorPhase1Y
                duration: 200
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: navigationBar
                property: "indicatorAnimationHeight"
                to: navigationBar.indicatorPhase1Height
                duration: 200
                easing.type: Easing.InCubic
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: navigationBar
                property: "indicatorAnimationY"
                to: navigationBar.indicatorPhase2Y
                duration: 400
                easing.type: Easing.OutQuint
            }
            NumberAnimation {
                target: navigationBar
                property: "indicatorAnimationHeight"
                to: navigationBar.indicatorPhase2Height
                duration: 400
                easing.type: Easing.OutQuint
            }
        }

        onRunningChanged: {
            if (!running && !navigationBar.indicatorSuppressHandoff) {
                navigationBar.indicatorAnimating = false
                indicatorHandoffTimer.restart()
            }
        }
    }

    Timer {
        id: indicatorHandoffTimer
        interval: Utils.animationSpeedMiddle
        repeat: false
        onTriggered: navigationBar.indicatorOverlayVisible = false
    }
    
    // 拖拽调整区域
    MouseArea {
        id: resizeHandle
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 4
        cursorShape: Qt.SizeHorCursor
        enabled: enableDragResize && !collapsed
        visible: enabled
        z: 1000
        
        property int startX: 0
        property int startWidth: 0
        
        onPressed: function(mouse) {
            startX = mouse.x
            startWidth = getEffectiveWidth()  // 从当前有效宽度开始拖拽
        }
        
        onPositionChanged: function(mouse) {
            if (pressed) {
                let delta = mouse.x - startX
                let newWidth = startWidth + delta
                
                // 限制在最小/最大宽度之间
                newWidth = Math.max(minNavbarWidth, Math.min(maxNavbarWidth, newWidth))
                
                // 确保是 4 的倍数
                newWidth = Math.round(newWidth / 4) * 4
                
                navigationBar.userResizedWidth = newWidth  // 存储到拖拽宽度
            }
        }
    }
}
