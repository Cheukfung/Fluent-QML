import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Progress Bar")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("The ProgressBar has two different visual representations:\n" +
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

            ProgressBar {
                indeterminate: true
                state: stateComboBox.model.get(stateComboBox.currentIndex).state
            }
        }

        showcase: [
            Text {
                text: qsTr("State")
            },
            ComboBox {
                id: stateComboBox
                model: ListModel {
                    ListElement { text: "Running"; state: ProgressBar.Running }
                    ListElement { text: "Paused"; state: ProgressBar.Paused }
                    ListElement { text: "Error"; state: ProgressBar.Error }
                }
                textRole: "text"
                currentIndex: 0
            }
        ]
    }

    Text {
        typography: Typography.BodyStrong
        text: qsTr("An determinate ProgressBar.")
    }

    Frame {
        Layout.fillWidth: true
        padding: 24

        RowLayout {
            spacing: 8

            ProgressBar {
                from: 0
                to: 100
                value: progressSlider.value
                state: stateComboBox.model.get(stateComboBox.currentIndex).state
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
    }
}
