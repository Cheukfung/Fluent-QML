import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("TimePicker")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Use a TimePicker to let users set a time in your app, for example to set a reminder. The TimePicker " +
            "displays three controls for hours, minutes, and AM/PM. These controls are easy to use with " +
            "touch or mouse, and they can be styled and configured in several different ways. "
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple TimePicker.")
        }
        ControlShowcase {
            width: parent.width
            TimePicker {
                enabled: !pickerSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: pickerSwitch
                    text: qsTr("Disable TimePicker")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A TimePicker using a 24-hour clock.")
        }
        Frame {
            width: parent.width
            padding: 18

            Column {
                Text {
                    text: qsTr("24 hour clock")
                }
                TimePicker {
                    use24Hour: true
                }
            }
        }
    }
}
