import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Avatar")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("Display a picture of a user/contact")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Select different looks for the avatar.")
        }
        ControlShowcase {
            width: parent.width
            Avatar {
                id: avatar
                source: typeGroup.checkedButton.text === "Profile Image"
                    ? "https://learn.microsoft.com/windows/uwp/contacts-and-calendar/images/shoulder-tap-static-payload.png"
                    : ""
                text: "Jane Doe"  // display name
                enabled: !buttonSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: buttonSwitch
                    text: qsTr("Disable Avatar")
                },
                Text {
                    text: qsTr("Profile Type")
                },
                ButtonGroup {
                    id: typeGroup
                },
                RadioButton {
                    text: qsTr("Profile Image")
                    ButtonGroup.group: typeGroup
                    checked: true
                },
                RadioButton {
                    text: qsTr("Display Name")
                    ButtonGroup.group: typeGroup
                }
            ]
        }
    }
}
