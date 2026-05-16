import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("ProgressRing")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("The ProgressRing has two different visual representations:\n" +
                "Indeterminate - shows that a task is ongoing, but doesn't block user interaction.\n" +
                "Determinate - shows how much progress has been made on a known amount of work."
        )
    }

    Text {
        typography: Typography.BodyStrong
        text: qsTr("An indeterminate ProgressBar.")
    }

    ControlShowcase {
        Layout.fillWidth: true

        Column {
            padding: 36
            spacing: 4

            ProgressRing {
                indeterminate: true
                state: stateComboBox.model.get(stateComboBox.currentIndex).state
                backgroundColor: colorComboBox.model.get(colorComboBox.currentIndex).value
            }
        }

        showcase: [
            Text {
                text: qsTr("State")
            },
            ComboBox {
                id: stateComboBox
                model: ListModel {
                    ListElement { text: "Running"; state: ProgressRing.Running }
                    ListElement { text: "Paused"; state: ProgressRing.Paused }
                    ListElement { text: "Error"; state: ProgressRing.Error }
                }
                textRole: "text"
                currentIndex: 0
            },
            Text {
                text: qsTr("Background Color")
            },
            ComboBox {
                id: colorComboBox
                model: ListModel {
                    ListElement { text: qsTr("Transparent"); value: "transparent" }
                    ListElement { text: qsTr("Light Gray"); value: "lightgray" }
                }
                textRole: "text"
                currentIndex: -1
                placeholderText: qsTr("Pick a color")
            }
        ]
    }

    Text {
        typography: Typography.BodyStrong
        text: qsTr("An determinate ProgressBar.")
    }

    ControlShowcase {
        Layout.fillWidth: true
        padding: 24

        RowLayout {
            spacing: 8

            ProgressRing {
                from: 0
                to: 100
                value: progressSlider.value
                state: stateComboBox.model.get(stateComboBox.currentIndex).state
                backgroundColor: colorComboBox2.model.get(colorComboBox2.currentIndex).value
            }

            Item {
                width: 16
            }

            Text {
                text: qsTr("Progress")
            }

            SpinBox {
                id: progressSlider
                from: 0
                to: 100
                stepSize: 1
                value: 50
            }
        }
        showcase: [
            Text {
                text: qsTr("Background Color")
            },
            ComboBox {
                id: colorComboBox2
                model: ListModel {
                    ListElement { text: qsTr("Transparent"); value: "transparent" }
                    ListElement { text: qsTr("Light Gray"); value: "lightgray" }
                }
                textRole: "text"
                currentIndex: -1
                placeholderText: qsTr("Pick a color")
            }
        ]
    }
}
