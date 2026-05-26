import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import "../../themes"
import "../../components"

Button {
    id: root

    property bool tight: false
    property bool inheritBarStyle: true
    property int toolButtonStyle: Qt.ToolButtonTextBesideIcon
    property int iconSize: 16

    flat: true
    highlighted: checked
    padding: 0
    icon.width: iconSize
    icon.height: iconSize
    implicitWidth: {
        if (isIconOnly())
            return tight ? 32 : 48

        if (toolButtonStyle === Qt.ToolButtonTextBesideIcon)
            return commandText.implicitWidth + 47

        if (toolButtonStyle === Qt.ToolButtonTextOnly)
            return commandText.implicitWidth + 32

        return Math.max(commandText.implicitWidth + 32, 48)
    }
    implicitHeight: toolButtonStyle === Qt.ToolButtonTextUnderIcon && !isIconOnly() ? 50 : 34

    function isIconOnly() {
        if (text === "")
            return true

        return toolButtonStyle === Qt.ToolButtonIconOnly || toolButtonStyle === Qt.ToolButtonFollowStyle
    }

    function triggerCommand() {
        if (root.action) {
            root.action.trigger()
            return
        }

        root.clicked()
    }

    contentItem: Item {
        anchors.fill: parent

        IconWidget {
            id: iconWidget
            size: root.iconSize
            icon: root.icon.name
            source: root.icon.source
            visible: root.toolButtonStyle !== Qt.ToolButtonTextOnly && (root.icon.name !== "" || root.icon.source.toString() !== "")
            color: root.enabled
                ? (root.highlighted && !root.flat
                    ? Theme.currentTheme.colors.textOnAccentColor
                    : Theme.currentTheme.colors.textColor)
                : Theme.currentTheme.colors.disabledColor

            anchors.verticalCenter: root.toolButtonStyle === Qt.ToolButtonTextUnderIcon && !root.isIconOnly() ? undefined : parent.verticalCenter
            anchors.horizontalCenter: root.isIconOnly() || root.toolButtonStyle === Qt.ToolButtonTextUnderIcon ? parent.horizontalCenter : undefined
            x: root.toolButtonStyle === Qt.ToolButtonTextBesideIcon && !root.isIconOnly() ? 11 : x
            y: root.toolButtonStyle === Qt.ToolButtonTextUnderIcon && !root.isIconOnly() ? 9 : y
        }

        Text {
            id: commandText
            typography: Typography.Body
            text: root.text
            visible: root.toolButtonStyle !== Qt.ToolButtonIconOnly && root.text !== ""
            color: root.enabled ? Theme.currentTheme.colors.textColor : Theme.currentTheme.colors.disabledColor
            elide: Text.ElideRight
            wrapMode: Text.NoWrap

            anchors.verticalCenter: root.toolButtonStyle === Qt.ToolButtonTextUnderIcon && !root.isIconOnly() ? undefined : parent.verticalCenter
            anchors.horizontalCenter: root.toolButtonStyle === Qt.ToolButtonTextUnderIcon || root.toolButtonStyle === Qt.ToolButtonTextOnly ? parent.horizontalCenter : undefined
            anchors.left: root.toolButtonStyle === Qt.ToolButtonTextBesideIcon ? parent.left : undefined
            anchors.leftMargin: root.toolButtonStyle === Qt.ToolButtonTextBesideIcon ? 28 : 0
            anchors.right: root.toolButtonStyle === Qt.ToolButtonTextBesideIcon ? parent.right : undefined
            anchors.rightMargin: root.toolButtonStyle === Qt.ToolButtonTextBesideIcon ? 10 : 0
            y: root.toolButtonStyle === Qt.ToolButtonTextUnderIcon && !root.isIconOnly() ? root.iconSize + 13 : y
            horizontalAlignment: root.toolButtonStyle === Qt.ToolButtonTextBesideIcon ? Text.AlignHCenter : Text.AlignLeft
        }
    }
}
