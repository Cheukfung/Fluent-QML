import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("DropDownButton")
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
            DropDownButton {
                text: qsTr("Email")
                enabled: !buttonSwitch.checked

                MenuItem {
                    text: qsTr("Send")
                }
                MenuItem {
                    text: qsTr("Reply")
                }
                MenuItem {
                    text: qsTr("Reply All")
                }
            }

            showcase: [
                CheckBox {
                    id: buttonSwitch
                    text: qsTr("Disable DropDownButton")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("DropDownButton with Icons")
        }
        Frame {
            width: parent.width
            DropDownButton {
                icon.name: "ic_fluent_mail_20_regular"
                text: qsTr("Email")

                MenuItem {
                    icon.name: "ic_fluent_send_20_filled"
                    text: qsTr("Send")
                }
                MenuItem {
                    icon.name: "ic_fluent_mail_arrow_up_20_regular"
                    text: qsTr("Reply")
                }
                MenuItem {
                    icon.name: "ic_fluent_mail_arrow_double_back_20_regular"
                    text: qsTr("Reply All")
                }
            }
        }
    }
}
