import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("TextField")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Use a TextField to let a user enter simple text input in your app. You can add a placeholder text " +
            "to let the user know what the TextField is for, and you can customize it in other ways."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple TextField.")
        }
        ControlShowcase {
            width: parent.width
            TextField {
                editable: !readOnlyBox.checked
            }

            showcase: CheckBox {
                id: readOnlyBox
                text: qsTr("ReadOnly")
                checked: false
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A TextField with a placholder text.")
        }
        Frame {
            width: parent.width
            TextField {
                width: 175
                placeholderText: qsTr("Name")
            }
        }
    }
}
