import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 2.15
import "../../themes"
import "../../components"


MenuItem {
    id: root

    Layout.fillWidth: true

    implicitWidth: {
        const leftMargin = 16;
        const arrowWidth = arrow.visible ? arrow.width + 16 : root.checked ? indicator.width + 16 : 0;
        const rightMargin = 16;
        return leftMargin + contentItem.implicitWidth + arrowWidth + rightMargin;
    }
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding,
                             34)

    property MenuItemGroup group  // 组

    checkable: group
    checked: group ? group.checkedButton === root : false

    onGroupChanged: {
        if (group)
            group.register(root)
    }

    Component.onDestruction: {
        if (group)
            group.unregister(root)
    }

    onTriggered: {
        if (group)
            group.updateCheck(root)
    }

    property var parentMenu: undefined

    // accessibility
    FocusIndicator {
        control: parent
        anchors.margins: 5
        anchors.topMargin: 0
        anchors.bottomMargin: 0
    }

    arrow: IconWidget {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.margins: 16
        color: Theme.currentTheme.colors.textSecondaryColor
        visible: root.subMenu
        icon: "ic_fluent_chevron_right_20_regular"
        size: 12
    }

    indicator: IconWidget {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.margins: 18
        icon: group ? group.exclusive ? "ic_fluent_circle_20_filled" : "ic_fluent_checkmark_20_filled"
            : "ic_fluent_checkmark_20_filled"
        width: 16
        size: group ? group.exclusive ? 7 : 16 : 16
        visible: root.checked
    }

    // 内容 / Content //
    contentItem: Item {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: (iconWidget.size ? 16 : 0) + (checkable ? indicator.width + 16 : 0)
        anchors.margins: 16

        implicitWidth: (iconWidget.size ? iconWidget.implicitWidth : 0)
                       + 16
                       + menuText.implicitWidth
                       + (shortcutText.visible ? 16 + shortcutText.implicitWidth : 0)
        implicitHeight: Math.max(menuText.implicitHeight, shortcutText.implicitHeight, iconWidget.implicitHeight)

        IconWidget {
            id: iconWidget
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            size: icon || source ? menuText.font.pixelSize * 1.25 : 0  // 图标大小 / Icon Size
            icon: root.icon.name
            source: root.icon.source
            visible: size > 0
        }
        Text {
            id: menuText
            anchors.left: iconWidget.size ? iconWidget.right : parent.left
            anchors.leftMargin: 16
            anchors.right: shortcutText.visible ? shortcutText.left : parent.right
            anchors.rightMargin: shortcutText.visible ? 16 : 0
            anchors.verticalCenter: parent.verticalCenter
            typography: Typography.Body
            text: root.text
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }
        Text {
            id: shortcutText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            typography: Typography.Caption
            text: root.action ? root.action.shortcut : ""
            color: Theme.currentTheme.colors.textSecondaryColor
            visible: text
        }
    }

    // 背景 / Background //
    background: Rectangle {
        anchors.fill: parent
        anchors.margins: 5
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        radius: Theme.currentTheme.appearance.buttonRadius
        color: enabled ? pressed ? Theme.currentTheme.colors.subtleTertiaryColor
            : hovered
            ? Theme.currentTheme.colors.subtleSecondaryColor
            : "transparent" : "transparent"

        Behavior on color { ColorAnimation { duration: Utils.animationSpeed; easing.type: Easing.OutQuart } }
    }

    // States //
    // 状态变化
    states: [
        State {
        name: "disabled"
            when: !enabled
            PropertyChanges {
                target: root
                opacity: 0.3628
            }
        }
    ]
}
