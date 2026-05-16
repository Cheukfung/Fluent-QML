import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("RadioButton")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("Use RadioButtons to let a user choose between mutually exclusive, related options. " +
                 "Generally contained within a RadioButtons group control.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A group of RadioButton controls in a layout group.")
        }
        ControlShowcase {
            width: parent.width
            RadioButton {
                text: qsTr("Option 1")
                enabled: !radioSwitch.checked
            }
            RadioButton {
                text: qsTr("Option 2")
                enabled: !radioSwitch.checked
            }
            RadioButton {
                text: qsTr("Option 3")
                enabled: !radioSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: radioSwitch
                    text: qsTr("Disable RadioButtons")
                }
            ]
        }
    }
}
