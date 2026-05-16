import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("SpinBox")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("Use SpinBox to allow user to enter algebraic equations and numeric input in your app. ")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple SpinBox.")
        }
        ControlShowcase {
            width: parent.width
            SpinBox {
                enabled: !spinSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: spinSwitch
                    text: qsTr("Disable SpinBox")
                }
            ]
        }
    }
}
