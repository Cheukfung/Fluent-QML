import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("CheckBox")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("CheckBox controls let the user select a combination of binary options. " +
          "In contrast, RadioButton controls allow the user to select from mutually exclusive options. " +
          "The indeterminate state is used to indicate that an option is set for some, but not all, child options. " +
          "Don't allow users to set an indeterminate state directly to indicate a third option.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A 2-state CheckBox.")
        }
        ControlShowcase {
            width: parent.width
            height: 100
            CheckBox {
                text: qsTr("Two-state CheckBox")
                enabled: !checkBoxSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: checkBoxSwitch
                    text: qsTr("Disable CheckBox")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A 3-state CheckBox.")
        }
        ControlShowcase {
            width: parent.width
            height: 100
            CheckBox {
                tristate: true
                text: qsTr("Three-state CheckBox")
                enabled: !checkBox3StateSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: checkBox3StateSwitch
                    text: qsTr("Disable CheckBox")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Using a 3-state CheckBox.")
        }
        ControlShowcase {
            width: parent.width

            ButtonGroup {
                id: childGroup
                exclusive: false
                checkState: parentBox.checkState
            }

            CheckBox {
                id: parentBox
                text: qsTr("Select all")
                checkState: childGroup.checkState
                enabled: !checkBoxGroupSwitch.checked
            }

            CheckBox {
                checked: true
                text: qsTr("Option 1")
                leftPadding: indicator.width
                ButtonGroup.group: childGroup
                enabled: !checkBoxGroupSwitch.checked
            }

            CheckBox {
                text: qsTr("Option 2")
                leftPadding: indicator.width
                ButtonGroup.group: childGroup
                enabled: !checkBoxGroupSwitch.checked
            }

            CheckBox {
                text: qsTr("Option 3")
                leftPadding: indicator.width
                ButtonGroup.group: childGroup
                enabled: !checkBoxGroupSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: checkBoxGroupSwitch
                    text: qsTr("Disable CheckBox")
                }
            ]
        }
    }
}
