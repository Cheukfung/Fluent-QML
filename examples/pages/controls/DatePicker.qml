import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("DatePicker")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Use a DatePicker to let users set a date in your app, for example to schedule an appointment. The DatePicker " +
            "displays three controls for month, date, and year. These controls are easy to use with " +
            "touch or mouse, and they can be styled and configured in several different ways. "
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple DatePicker.")
        }
        ControlShowcase {
            width: parent.width
            DatePicker {
                id: datePicker1
                enabled: !pickerSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: pickerSwitch
                    text: qsTr("Disable DatePicker")
                },
                Button {
                    text: qsTr("Set Random Date")
                    onClicked: {
                        let year = Math.floor(Math.random() * (datePicker1.endYear - datePicker1.startYear) + datePicker1.startYear)
                        let month = Math.floor(Math.random() * (12 - 1) + 1)
                        let day = Math.floor(Math.random() * (28 - 1) + 1)
                        datePicker1.setDate(year + "-" + month + "-" + day)
                    }
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A DatePicker with localized text and year hidden.")
        }
        ControlShowcase {
            width: parent.width
            padding: 18

            DatePicker {
                id: datePicker
                // yearVisible: false
            }

            showcase: [
                Text {
                    text: qsTr("Locale")
                },
                ComboBox {
                    model: ["en_US", "fr_FR", "de_DE", "es_ES", "it_IT", "ja_JP", "ko_KR", "zh_CN", "zh_TW"]
                    currentIndex: 0
                    onCurrentIndexChanged: {
                        datePicker.locale = Qt.locale(model[currentIndex])
                    }
                },
                Button {
                    text: qsTr("Set Random Date")
                    onClicked: {
                        let year = Math.floor(Math.random() * (datePicker.endYear - datePicker.startYear) + datePicker.startYear)
                        let month = Math.floor(Math.random() * (12 - 1) + 1)
                        let day = Math.floor(Math.random() * (28 - 1) + 1)
                        datePicker.setDate(year + "-" + month + "-" + day)
                    }
                }
            ]
        }
    }
}
