import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("InfoBadge")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Badging is a non-intrusive and intuitive way to display notifications or bring focus to an area within " +
            "an app - whether that be for notifications, indicating new content, or showing an alert. "
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Different InfoBadge styles")
        }
        ControlShowcase {
            width: parent.width
            height: 100

            RowLayout {
                x: parent.width / 2 - implicitWidth / 2
                height: parent.height
                spacing: 20

                InfoBadge {
                    Layout.alignment: Qt.AlignVCenter
                    severity: severityComboBox.model.get(severityComboBox.currentIndex).state
                }
                InfoBadge {
                    Layout.alignment: Qt.AlignVCenter
                    severity: severityComboBox.model.get(severityComboBox.currentIndex).state
                    count: 10
                }
                InfoBadge {
                    Layout.alignment: Qt.AlignVCenter
                    severity: severityComboBox.model.get(severityComboBox.currentIndex).state
                    dot: true
                }
            }

            showcase: [
                Text {
                    text: qsTr("Styles")
                },
                ComboBox {
                    id: severityComboBox
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
            text: qsTr("Different InfoBadge styles without solid")
        }
        ControlShowcase {
            width: parent.width
            height: 100

            RowLayout {
                x: parent.width / 2 - implicitWidth / 2
                height: parent.height
                spacing: 20

                InfoBadge {
                    Layout.alignment: Qt.AlignVCenter
                    severity: severityComboBox2.model.get(severityComboBox2.currentIndex).state
                    solid: false
                }
                InfoBadge {
                    Layout.alignment: Qt.AlignVCenter
                    severity: severityComboBox2.model.get(severityComboBox2.currentIndex).state
                    count: 10
                    solid: false
                }
                InfoBadge {
                    Layout.alignment: Qt.AlignVCenter
                    severity: severityComboBox2.model.get(severityComboBox2.currentIndex).state
                    text: qsTr("Badge")
                    solid: false
                }
                InfoBadge {
                    Layout.alignment: Qt.AlignVCenter
                    severity: severityComboBox2.model.get(severityComboBox2.currentIndex).state
                    dot: true
                    solid: false
                }
            }

            showcase: [
                Text {
                    text: qsTr("Styles")
                },
                ComboBox {
                    id: severityComboBox2
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
}
