import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Button")
    docsUrl: "https://ui.rinlit.cn/BasicInput/Button.html"

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("The Button control provides a Click event to respond to user " +
          "input from a touch, mouse, keyboard, stylus, or other input device. " +
          "You can put different kinds of content in a button, such as text " +
          "or an image, or you can restyle a button to give it a new look.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple Button with text content.")
        }
        ControlShowcase {
            width: parent.width
            height: 100
            Button {
                text: qsTr("Standard QML Button")
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

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A Button with graphical content.")
        }
        Frame {
            width: parent.width
            height: 85

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Button {
                    icon.source: Qt.resolvedUrl("../../assets/BA_Pic_Shiroko-chibi.png")
                    text: qsTr("Sunaookami Shiroko")
                    ToolTip {
                        delay: 500
                        text: qsTr("icon.source: Qt.resolvedUrl(\"../../assets/BA_Pic_Shiroko-chibi.png\")")
                        visible: parent.hovered
                    }
                }
                Button {
                    icon.name: "ic_fluent_button_20_regular"
                    text: qsTr("Button with Icon")
                    ToolTip {
                        delay: 500
                        text: qsTr("icon.name: \"ic_fluent_button_20_regular\"")
                        visible: parent.hovered
                    }
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Wrapping Buttons with large content.")
        }
        Frame {
            width: parent.width

            Column {
                anchors.fill: parent
                spacing: 8
                Button {
                    width: parent.width
                    text: qsTr("This is some text that is too long and the text will get cut off.")
                }
                RowLayout {
                    width: parent.width
                    spacing: 8
                    Button {
                        text: qsTr("This is some text \nthat is too long \nbut with wrapping.")
                    }
                    Button {
                        Layout.fillWidth: true
                        text: qsTr("This is some text that is too long and the text will get cut off.")
                    }
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Accent style applied to Button.")
        }
        ControlShowcase {
            width: parent.width
            height: 100
            Button {
                highlighted: true
                text: qsTr("Accent Style Button")
                enabled: !buttonAccentSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: buttonAccentSwitch
                    text: qsTr("Disable Button")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Flat style applied to Button.")
        }
        ControlShowcase {
            width: parent.width
            height: 100
            Button {
                flat: true
                text: qsTr("Flat Style Button")
                enabled: !buttonFlatSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: buttonFlatSwitch
                    text: qsTr("Disable Button")
                }
            ]
        }
    }
}
