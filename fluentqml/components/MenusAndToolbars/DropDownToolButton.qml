import QtQuick 2.15
import "../../components"

CommandButton {
    id: root

    default property alias contentData: menu.contentData
    property alias menu: menu

    inheritBarStyle: false
    toolButtonStyle: text === "" ? Qt.ToolButtonIconOnly : Qt.ToolButtonTextBesideIcon
    implicitWidth: text === "" ? 48 : commandTextWidth.implicitWidth + 63

    Menu {
        id: menu
    }

    Text {
        id: commandTextWidth
        visible: false
        typography: Typography.Body
        text: root.text
    }

    IconWidget {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        icon: "ic_fluent_chevron_down_20_filled"
        size: 10
        color: root.enabled ? Theme.currentTheme.colors.textSecondaryColor : Theme.currentTheme.colors.disabledColor
    }

    onClicked: {
        if (menu.count > 0) {
            menu.open()
        }
    }
}
