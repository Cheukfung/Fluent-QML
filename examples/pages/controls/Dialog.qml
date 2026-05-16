import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    id: page
    title: "Dialog"

    // dialog //
    Dialog {
        id: basicDialog
        title: qsTr("This is a dialog")
        modal: true
        Text {
            Layout.fillWidth: true
            text: qsTr("This a dialog with basic content. \nMeow")
        }
        onAccepted: {
            floatLayer.createInfoBar({text: "Accepted"})
            cuteText.text = "Wow! You accepted! ヾ(≧▽≦*)o"
        }
        onRejected: {
            floatLayer.createInfoBar({text: "Rejected"})
            cuteText.text = "Hmm... You rejected ╥﹏╥"
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
    }

    // customDialog //
    Dialog {
        id: customDialog
        title: qsTr("Dialog Meow")
        modal: true
        width: 500
        Text {
            Layout.fillWidth: true
            text: qsTr("This a dialog with custom content.")
        }
        InfoBar {
            Layout.fillWidth: true
            severity: Severity.Info
            title: qsTr("Attention")
            text: qsTr("You can customize the title, text, and severity to popup a custom InfoBar.")
            closable: false
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Column {
                Layout.fillWidth: true
                spacing: 4
                TextField {
                    id: title
                    width: parent.width
                    placeholderText: qsTr("InfoBarTitle")
                    text: qsTr("Custom Title")
                }
                TextField {
                    id: text
                    width: parent.width
                    placeholderText: qsTr("InfoBarText")
                    text: qsTr("Custom Text")
                }
            }
            Column {
                Layout.fillWidth: true
                Text {
                    text: qsTr("Severity")
                }
                ComboBox {
                    id: severity
                    model: ListModel {
                        ListElement { text: "Info"; state: Severity.Info }
                        ListElement { text: "Success"; state: Severity.Success }
                        ListElement { text: "Warning"; state: Severity.Warning }
                        ListElement { text: "Error"; state: Severity.Error }
                    }
                    textRole: "text"
                    currentIndex: 0
                }
            }
        }
        onAccepted: {
            floatLayer.createInfoBar({
                title: title.text,
                text: text.text,
                severity: severity.model.get(severity.currentIndex).state
            })
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
    }

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr(
            "Use a ContentDialog to show relavant information or to provide a modal dialog experience "+
            "that can show any QML content."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
                text: "A dialog with basic content."
        }
        Frame {
            width: parent.width
            Row {
                spacing: 8
                Button {
                    text: qsTr("Show Dialog")
                    onClicked: basicDialog.open()
                }
                Text {
                    id: cuteText
                    verticalAlignment: Qt.AlignVCenter
                    text: qsTr("← Nyaa~ Click this Button ~UwU~")
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4
        Text {
            typography: Typography.BodyStrong
                text: "A dialog with custom content."
        }
        Frame {
            width: parent.width
            Row {
                spacing: 8
                Button {
                    text: qsTr("Show Dialog")
                    onClicked: customDialog.open()
                }
                Text {
                    id: cuteText2
                    verticalAlignment: Qt.AlignVCenter
                    text: qsTr("← Nyaa~ Click this Button ~UwU~")
                }
            }
        }
    }
}
