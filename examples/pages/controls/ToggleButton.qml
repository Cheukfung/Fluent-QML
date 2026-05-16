import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("ToggleButton")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("A ToggleButton looks like a Button, but works like a CheckBox. It typically has two states,  " +
                 "checked (on) or unchecked (off).")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple ToggleButton with text content.")
        }
        ControlShowcase {
            width: parent.width
            ToggleButton {
                text: qsTr("ToggleButton")
                enabled: !buttonSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: buttonSwitch
                    text: qsTr("Disable ToggleButton")
                }
            ]
        }
    }
}
