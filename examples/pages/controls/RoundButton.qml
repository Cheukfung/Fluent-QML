import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("RoundButton")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "A RoundButton looks like a Button, except that it has a radius property which allows " +
            "the corners to be rounded without having to customize the background."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple RoundButton.")
        }
        ControlShowcase {
            width: parent.width
            RoundButton {
                text: qsTr("RoundButton")
                enabled: !buttonSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: buttonSwitch
                    text: qsTr("Disable Button")
                }
            ]
        }
    }
}
