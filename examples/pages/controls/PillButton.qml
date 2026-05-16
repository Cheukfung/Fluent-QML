import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("PillButton")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("A PillButton looks and works like a ToggleButton. It typically has two states,  " +
                 "checked (on) or unchecked (off).")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple PillButton.")
        }
        ControlShowcase {
            width: parent.width
            PillButton {
                text: qsTr("PillButton")
                enabled: !buttonSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: buttonSwitch
                    text: qsTr("Disable PillButton")
                }
            ]
        }
    }
}
