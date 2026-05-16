import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Expander")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "The Expander has a header and can expand to show a body with more content. Use an Expander when some " +
            "content is only relevant some of the time (for example to read more information or access additional " +
            "options for an item)."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("An Expander with text in the header and content areas")
        }
        ControlShowcase {
            width: parent.width
            Expander {
                width: 228
                contentHeight: 50
                expandDirection: expandDirectionCombobox.currentIndex === 0
                    ? Expander.Up : Expander.Down
                text: qsTr("This text is in the header")

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("This is in th content")
                }
            }

            showcase: [
                Text {
                    text: qsTr("ExpandDirection")
                },
                ComboBox {
                    id: expandDirectionCombobox
                    model: ["Up", "Down"]
                    currentIndex: 1
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("An Expander with other controls in the header and content")
        }
        Frame {
            width: parent.width

            Row {
                Expander {
                    header: ToggleButton {
                        text: qsTr("This is a ToggleButton in the header")
                    }

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("This is a Button in the content")
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
            text: qsTr("Modifying Expanders content alignment")
        }
        Frame {

            width: parent.width

            Row {
                Expander {
                    width: Math.min(parent.parent.width, 500)
                    header: ToggleButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("This ToggleButton is centered")
                    }

                    Button {
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("This Button is left aligned")
                    }
                }
            }
        }
    }
}
