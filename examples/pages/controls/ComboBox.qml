import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("ComboBox")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("Use a ComboBox when you need to conserve on-screen space and when users select only one option " +
          "at a time. A ComboBox shows only the currently selected item.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A ComboBox with items defined inline and its width set.")
        }
        ControlShowcase {
            width: parent.width

            ComboBox {
                id: comboBox
                width: 200
                model: ["Blue", "Green", "Red", "Yellow"]
                currentIndex: -1
                placeholderText: qsTr("Pick a color")
                enabled: !comboBoxSwitch.checked
            }

            Rectangle {
                width: 100
                height: 30
                color: {
                    if (comboBox.currentIndex === 0) {
                        return "#0000FF"  // Blue
                    } else if (comboBox.currentIndex === 1) {
                        return "#008000"  // Green
                    } else if (comboBox.currentIndex === 2) {
                        return "#FF0000"  // Red
                    } else if (comboBox.currentIndex === 3) {
                        return "#FFFF00"  // Yellow
                    } else {
                        return "transparent"
                    }
                }
            }

            showcase: [
                CheckBox {
                    id: comboBoxSwitch
                    text: qsTr("Disable ComboBox")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A ComboBox with its Model set.")
        }
        ControlShowcase {
            width: parent.width
            spacing: 12

            ComboBox {
                id: comboBoxFont
                width: 200
                model: ["Arial", "Comic Sans MS", "Courier New", "Segoe UI", "Times New Roman"]
                currentIndex: 2
                placeholderText: qsTr("Pick a font")
                enabled: !comboBoxFontSwitch.checked
            }

            Text {
                text: qsTr("The quick brown fox jumps over the lazy dog")
                font.family: comboBoxFont.currentText
                font.pixelSize: 14
            }

            showcase: [
                CheckBox {
                    id: comboBoxFontSwitch
                    text: qsTr("Disable ComboBox")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("An editable ComboBox with its Model set.")
        }
        ControlShowcase {
            width: parent.width
            spacing: 12

            ComboBox {
                id: comboBoxSize
                width: 200
                editable: true
                model: ListModel {
                    id: sizeModel
                    ListElement { value: 8 }
                    ListElement { value: 9 }
                    ListElement { value: 10 }
                    ListElement { value: 11 }
                    ListElement { value: 12 }
                    ListElement { value: 14 }
                    ListElement { value: 16 }
                    ListElement { value: 18 }
                    ListElement { value: 20 }
                    ListElement { value: 24 }
                    ListElement { value: 28 }
                    ListElement { value: 36 }
                    ListElement { value: 48 }
                    ListElement { value: 72 }
                }
                currentIndex: 2
                placeholderText: qsTr("Pick a size")
                enabled: !comboBoxSizeSwitch.checked

                onAccepted: {
                    if (find(editText) === -1) {
                        let num = Number(editText)
                        if (!isNaN(num)) {
                            sizeModel.append({ value: num })
                        } else {
                            warnDialog.open()
                        }
                    }
                }
            }

            Text {
                typography: Typography.Body
                font.pixelSize: comboBoxSize.currentText
                text: qsTr("The quick brown fox jumps over the lazy dog")
            }

            showcase: [
                CheckBox {
                    id: comboBoxSizeSwitch
                    text: qsTr("Disable ComboBox")
                }
            ]
        }
    }

    Dialog {
        id: warnDialog
        modal: true
        Text {
            Layout.fillWidth: true
            text: qsTr("The font size must be a number.")
        }
        standardButtons: Dialog.Ok
    }
}
