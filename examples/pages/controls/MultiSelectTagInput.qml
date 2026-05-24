import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("MultiSelectTagInput")

    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Use a MultiSelectTagInput when users can choose multiple values from suggestions and review " +
            "their choices as removable tags."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A basic MultiSelectTagInput.")
        }

        ControlShowcase {
            width: parent.width
            spacing: 12

            MultiSelectTagInput {
                id: tagInput
                width: 360
                placeholderText: qsTr("Select tags")
                model: [
                    "Design",
                    "QML",
                    "Python",
                    "Fluent",
                    "Desktop",
                    "Accessibility",
                    "Animation"
                ]
                selectedItems: ["QML", "Fluent"]
                allowCustomText: allowCustomTextBox.checked
                editable: !disabledBox.checked

                onAccepted: selectedText.text = selectedItems.join(", ")
            }

            Text {
                id: selectedText
                width: parent.width
                typography: Typography.Caption
                text: tagInput.selectedItems.join(", ")
            }

            showcase: [
                CheckBox {
                    id: allowCustomTextBox
                    text: qsTr("Allow custom text")
                },
                CheckBox {
                    id: disabledBox
                    text: qsTr("Disabled")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A MultiSelectTagInput with a ListModel.")
        }

        Frame {
            width: parent.width

            MultiSelectTagInput {
                width: 360
                placeholderText: qsTr("Pick frameworks")
                textRole: "name"
                model: ListModel {
                    ListElement { name: "Qt Quick" }
                    ListElement { name: "Fluent QML" }
                    ListElement { name: "PySide6" }
                    ListElement { name: "WinUI" }
                    ListElement { name: "Kirigami" }
                }
            }
        }
    }
}
