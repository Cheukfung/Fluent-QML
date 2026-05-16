import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Switch")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Use Switch controls to present users with exactly two mutually exclusive options (like on/off), " +
            "where choosing an option results in an immediate commit. A switch should have a single label"
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple Switch.")
        }
        ControlShowcase {
            width: parent.width
            Switch {
                enabled: !switchSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: switchSwitch
                    text: qsTr("Disable Switch")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple Switch.")
        }
        Frame {
            width: parent.width
            padding: 20
            Column {
                spacing: 16
                Text {
                    text: qsTr("Toggle work")
                }
                Row {
                    spacing: 32
                    Switch {
                        id: toggleWorkSwitch
                        checked: true
                        checkedText: qsTr("Working")
                        uncheckedText: qsTr("Do work")
                    }
                    ProgressBar {
                        anchors.verticalCenter: parent.verticalCenter
                        indeterminate: true
                        visible: toggleWorkSwitch.checked
                    }
                }
            }
        }
    }
}
