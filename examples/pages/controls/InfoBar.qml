import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("InfoBar")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Use an InfoBar control when a user should be informed of, acknowledge, " +
            "or take action on a changed application state. "+
            "By default the notification will remain in the content area until closed by the user but will not " +
            "necessarily break user flow."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
                text: "A closable InfoBar with options to change its Severity"
        }

        ControlShowcase {
            width: parent.width
            padding: 48

            InfoBar {
                id: infoBar
                width: parent.width
                severity: infoBarSeverityComboBox.model.get(infoBarSeverityComboBox.currentIndex).state
                title: qsTr("Title")
                text: qsTr("Essential app message for your users to be informed of, acknowledge, or take action on.")
                visible: infoBarSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: infoBarSwitch
                    checked: infoBar.visible
                    onCheckedChanged: {
                        infoBar.visible = infoBarSwitch.checked
                    }
                    text: qsTr("Is Open")
                },
                Text {
                    text: qsTr("Severity")
                },
                ComboBox {
                    id: infoBarSeverityComboBox
                    model: ListModel {
                        ListElement { text: "Info"; state: Severity.Info }
                        ListElement { text: "Success"; state: Severity.Success }
                        ListElement { text: "Warning"; state: Severity.Warning }
                        ListElement { text: "Error"; state: Severity.Error }
                    }
                    textRole: "text"
                    currentIndex: 0
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
                text: "A closeable InfoBar with a long or short text message and various buttons"
        }

        ControlShowcase {
            width: parent.width
            padding: 48

            InfoBar {
                id: infoBar2
                width: parent.width
                title: qsTr("World Setting")
                text: infoBarTextLengthComboBox.model.get(infoBarTextLengthComboBox.currentIndex).content
                visible: infoBarSwitch2.checked

                customContent: [
                    Button {
                        text: qsTr("Action")
                        visible: infoBarButtonComboBox.currentIndex === 1
                    },
                    Hyperlink {
                        text: qsTr("What is Blue Archive?")
                        openUrl: "https://bluearchive.nexon.com/"
                        visible: infoBarButtonComboBox.currentIndex === 2
                    }
                ]
            }

            showcase: [
                CheckBox {
                    id: infoBarSwitch2
                    checked: infoBar2.visible
                    onCheckedChanged: {
                        infoBar2.visible = infoBarSwitch2.checked
                    }
                    text: qsTr("Is Open")
                },
                Text {
                    text: qsTr("Message Length")
                },
                ComboBox {
                    id: infoBarTextLengthComboBox
                    textRole: "text"
                    model: ListModel {
                        ListElement {
                            text: "Short"; content: qsTr("A story of friendship, youth, and love is about to unfold.")
                        }
                        ListElement {
                            text: "Long";
                            content: qsTr(
                                "Kivotos — a mysterious and vast land where girls with strange halos above their heads live. However, the peaceful life under the management of the Prime Student Council is shattered when the president suddenly disappears without a trace."
                            )
                        }
                    }
                },
                Text {
                    text: qsTr("Action Button")
                },
                ComboBox {
                    id: infoBarButtonComboBox
                    model: ["None", "Button", "Hyperlink"]
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
                text: "A closable InfoBar with options to display the close button and icon"
        }

        ControlShowcase {
            width: parent.width
            padding: 48

            InfoBar {
                id: infoBar3
                width: parent.width
                title: qsTr("Title")
                text: qsTr("Essential app message for your users to be informed of, acknowledge, or take action on.")
                closable: infoBarColsable.checked
                iconVisible: infoBarIcon.checked
                visible: infoBarSwitch3.checked
            }

            showcase: [
                CheckBox {
                    id: infoBarSwitch3
                    checked: infoBar3.visible
                    onCheckedChanged: {
                        infoBar3.visible = infoBarSwitch3.checked
                    }
                    text: qsTr("Is Open")
                },
                CheckBox {
                    id: infoBarIcon
                    text: qsTr("Is Icon Visible")
                    checked: true
                },
                CheckBox {
                    id: infoBarColsable
                    text: qsTr("Is Closable")
                    checked: true
                }
            ]
        }
    }


    Column {
        Layout.fillWidth: true

        Text {
            typography: Typography.BodyStrong
                text: "InfoBar with different popup positions & styles"
        }
        Frame {
            width: parent.width
            Column {
                spacing: 6
                Row {
                    spacing: 12
                    Column {
                        Text {
                        text: qsTr("Location")
                        }
                        ComboBox {
                            id: positionComboBox
                            model: ListModel {
                                ListElement { text: "Top"; pos: Position.Top }
                                ListElement { text: "Bottom"; pos: Position.Bottom }
                                ListElement { text: "TopLeft"; pos: Position.TopLeft }
                                ListElement { text: "TopRight"; pos: Position.TopRight }
                                ListElement { text: "BottomLeft"; pos: Position.BottomLeft }
                                ListElement { text: "BottomRight"; pos: Position.BottomRight }
                            }
                            textRole: "text"
                            currentIndex: 0
                        }
                    }
                    Column {
                        Text {
                            text: qsTr("Style")
                        }
                        ComboBox {
                            id: infoBarSeverityComboBox2
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
                    TextField {
                        width: 100
                        id: infoBarTitle
                        placeholderText: qsTr("Title")
                    }
                    TextField {
                        width: 200
                        id: infoBarText
                        placeholderText: qsTr("Text")
                    }
                }
                Row {
                    spacing: 6
                    Button {
                        text: qsTr("Popup!")
                        highlighted: true
                        icon.name: "ic_fluent_alert_on_20_regular"
                        onClicked: {
                            floatLayer.createInfoBar({
                                severity: infoBarSeverityComboBox2.model.get(infoBarSeverityComboBox2.currentIndex).state,
                                title: infoBarTitle.text,
                                text: infoBarText.text,
                                position: positionComboBox.model.get(positionComboBox.currentIndex).pos
                            })
                        }
                    }
                    Button {
                        Component {
                            id: customInfoBar
                            InfoBar {
                                timeout: 2000
                                severity: Severity.Success
                                title: qsTr("Sunaookami Shiroko")
                                text: qsTr("\"The more prepared you are, the better. It's a simple rule.\"")
                                customContent: [
                                    Button {
                                        text: "Click Me!"
                                        onClicked: {
                                            floatLayer.createInfoBar({title: "Sunaookami Shiroko", text: "Clicked!"})
                                        }
                                    },
                                    IconWidget {
                                        size: 64
                                        source: Qt.resolvedUrl("../../assets/BA_Pic_Shiroko-chibi.png")
                                    }
                                ]
                            }
                        }
                        text: qsTr("Popup a custom InfoBar")
                        icon.name: "ic_fluent_alert_on_20_regular"
                        onClicked: {
                            floatLayer.createCustom(customInfoBar)
                        }
                    }
                }
            }
        }
    }
}
