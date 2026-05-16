import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Popup")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "The Popup Control allows your app to display temporary content above other UI elements. It can be used " +
            "for lightweight interactions such as tooltips, notifications, or custom floating panels."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple Popup.")
        }
        ControlShowcase {
            width: parent.width
            Button {
                text: qsTr("Open Popup")
                onClicked: {
                    popup.open()
                }

                Popup {
                    id: popup
                    width: 200
                    height: 160
                    modal: modalSwitch.checked

                    position: positionComboBox.model.get(positionComboBox.currentIndex).pos

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: qsTr("Simple Popup")
                        }
                        Button {
                            text: qsTr("Close")
                            onClicked: popup.close()
                        }
                    }
                }
            }

            showcase: [
                Text {
                    text: qsTr("Position")
                },
                ComboBox {
                    id: positionComboBox
                    model: ListModel {
                        ListElement { text: "Top"; pos: Position.Top }
                        ListElement { text: "Bottom"; pos: Position.Bottom }
                        ListElement { text: "Left"; pos: Position.Left }
                        ListElement { text: "Center"; pos: Position.Center }
                        ListElement { text: "Right"; pos: Position.Right }
                    }
                    textRole: "text"
                    currentIndex: 1
                },
                CheckBox {
                    id: modalSwitch
                    text: qsTr("Enable modal")
                }
            ]
        }
    }
}
