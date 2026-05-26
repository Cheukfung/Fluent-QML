import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import "../../components"

Control {
    id: root

    default property alias contentData: commandRow.data
    property var hiddenActions: []
    property int commandSpacing: 4
    property int toolButtonStyle: Qt.ToolButtonIconOnly
    property bool buttonTight: false
    property int iconSize: 16
    property var commandItems: []
    property var overflowItems: []
    readonly property var menuItems: overflowItems.concat(hiddenActions)

    implicitWidth: suitableWidth()
    implicitHeight: 34
    padding: 0

    function suitableWidth() {
        let width = 0
        for (let i = 0; i < commandItems.length; ++i) {
            const child = commandItems[i]
            width += itemWidth(child)
            if (i > 0)
                width += commandSpacing
        }

        if (hiddenActions.length > 0)
            width += (commandItems.length > 0 ? commandSpacing : 0) + moreButton.implicitWidth

        return width
    }

    function itemWidth(item) {
        return Math.max(item.implicitWidth || 0, item.minimumWidth || 0)
    }

    function itemHeight(item) {
        return Math.max(item.implicitHeight || 0, item.minimumHeight || 0)
    }

    function resizeToSuitableWidth() {
        width = suitableWidth()
    }

    function refreshCommandItems() {
        const items = []
        for (let i = 0; i < commandRow.children.length; ++i) {
            const child = commandRow.children[i]
            if (child !== moreButton)
                items.push(child)
        }
        commandItems = items
        Qt.callLater(updateOverflow)
    }

    function applyButtonOptions() {
        for (let i = 0; i < commandItems.length; ++i) {
            const child = commandItems[i]
            if (child.inheritBarStyle !== undefined && child.inheritBarStyle) {
                child.toolButtonStyle = toolButtonStyle
                child.tight = buttonTight
                child.iconSize = iconSize
            }
        }
    }

    function updateOverflow() {
        applyButtonOptions()

        function layout(availableWidth, reserveMoreButton) {
            const nextOverflow = []
            let x = 0
            let overflowStarted = false
            const maxWidth = Math.max(0, availableWidth - (reserveMoreButton ? moreButton.implicitWidth + commandSpacing : 0))

            for (let i = 0; i < commandItems.length; ++i) {
                const child = commandItems[i]
                const childWidth = itemWidth(child)
                const childHeight = itemHeight(child)
                const itemSpacing = x > 0 ? commandSpacing : 0

                if (!overflowStarted && x + itemSpacing + childWidth <= maxWidth) {
                    child.visible = true
                    child.x = x + itemSpacing
                    child.y = Math.round((root.height - childHeight) / 2)
                    child.width = childWidth
                    child.height = childHeight
                    x = child.x + childWidth
                } else {
                    overflowStarted = true
                    child.visible = false
                    nextOverflow.push(child)
                }
            }

            return nextOverflow
        }

        let nextOverflow = layout(root.width, hiddenActions.length > 0)
        const needsMoreButton = nextOverflow.length > 0 || hiddenActions.length > 0
        nextOverflow = layout(root.width, needsMoreButton)
        overflowItems = nextOverflow

        moreButton.visible = needsMoreButton
        if (needsMoreButton) {
            const visibleCount = commandItems.length - nextOverflow.length
            if (visibleCount > 0) {
                const lastItem = commandItems[visibleCount - 1]
                moreButton.x = lastItem.x + lastItem.width + commandSpacing
            } else {
                moreButton.x = 0
            }
            moreButton.y = Math.round((root.height - moreButton.implicitHeight) / 2)
            moreButton.width = moreButton.implicitWidth
            moreButton.height = moreButton.implicitHeight
        }
    }

    background: Item {}

    contentItem: Item {
        Item {
            id: commandRow
            anchors.fill: parent

            onChildrenChanged: root.refreshCommandItems()
        }

        MoreActionsButton {
            id: moreButton
            visible: false
            onClicked: moreMenu.open()

            Menu {
                id: moreMenu

                Instantiator {
                    model: root.menuItems.length

                    MenuItem {
                        readonly property var command: root.menuItems[index]

                        text: command && command.text ? command.text : ""
                        icon.name: command && command.icon ? command.icon.name : ""
                        enabled: command ? command.enabled : true
                        visible: text !== ""

                        onTriggered: {
                            if (command && command.triggerCommand) {
                                command.triggerCommand()
                            } else if (command && command.action) {
                                command.action.trigger()
                            } else if (command && command.trigger) {
                                command.trigger()
                            }
                        }
                    }

                    onObjectAdded: function(index, object) {
                        moreMenu.insertItem(index, object)
                    }

                    onObjectRemoved: function(index, object) {
                        moreMenu.removeItem(object)
                    }
                }
            }
        }
    }

    onWidthChanged: Qt.callLater(updateOverflow)
    onHeightChanged: Qt.callLater(updateOverflow)
    onToolButtonStyleChanged: Qt.callLater(updateOverflow)
    onButtonTightChanged: Qt.callLater(updateOverflow)
    onIconSizeChanged: Qt.callLater(updateOverflow)
    onHiddenActionsChanged: Qt.callLater(updateOverflow)
    Component.onCompleted: root.refreshCommandItems()
}
