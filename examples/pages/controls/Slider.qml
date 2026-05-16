import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Slider")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("Use a Slider when you want your users to be able to set defined, contiguous values (such as volume or brightness) " +
                 "or a range of discrete values (such as screen resolutions settings).")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple Slider")
        }
        ControlShowcase {
            width: parent.width
            Slider {
                width: 200
                enabled: !sliderSwitch.checked
            }

            showcase: [
                CheckBox {
                    id: sliderSwitch
                    text: qsTr("Disable Slider")
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A Slider with range and step specified.")
        }
        ControlShowcase {
            width: parent.width
            height: 200
            Slider {
                width: 200
                from: minSlider.value
                to: maxSlider.value
                stepSize: stepSlider.value
                value: 800
            }

            showcase: [
                Text { text: qsTr("Minimum:") },
                Slider {
                    id: minSlider
                    from: 0
                    to: 1000
                    stepSize: 10
                    value: 500
                },
                Text { text: qsTr("Maximum:") },
                Slider {
                    id: maxSlider
                    from: 0
                    to: 1000
                    stepSize: 10
                    value: 800
                },
                Text { text: qsTr("Step size:") },
                Slider {
                    id: stepSlider
                    from: 1
                    to: 100
                    stepSize: 1
                    value: 10
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A Slider with tick marks.")
        }
        ControlShowcase {
            width: parent.width
            height: 150
            Slider {
                width: 300
                from: 0
                to: 100
                stepSize: 20
                tickmarks: true
                snapMode: stepValuesSnap.checked? Slider.NoSnap : ticksSnap.checked? Slider.SnapAlways : Slider.NoSnap
            }

            showcase: [
                Text { text: qsTr("Snaps to:") },
                Column {
                    spacing: 4
                    RadioButton {
                        id: stepValuesSnap
                        text: qsTr("StepValues")
                        checked: true
                    }

                    RadioButton {
                        id: ticksSnap
                        text: qsTr("Ticks")
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
            text: qsTr("A vertical Slider with range and tick marks specified.")
        }
        Frame {
            width: parent.width
            height: 125
            Slider {
                height: 100
                orientation: Qt.Vertical
                from: 0
                to: 100
                stepSize: 1
                tickFrequency: 20
                tickmarks: true
                snapMode: stepValuesSnap.checked? Slider.NoSnap : ticksSnap.checked? Slider.SnapAlways : Slider.NoSnap
            }
        }
    }
}
