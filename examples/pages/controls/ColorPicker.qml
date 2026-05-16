import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("ColorPicker")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("A selectable color spectrum")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("ColorPicker Properties")
        }
        ControlShowcase {
            width: parent.width
            showcaseWidth: 300

            ColorPicker {
                id: picker
                moreVisible: moreBtnCheckBox.checked
                colorSliderVisible: colorSliderCheckBox.checked
                colorChannelInputVisible: colorChannelCheckBox.checked
                hexInputVisible: hexCheckBox.checked
                alphaSliderVisible: alphaSliderCheckBox.checked
                alphaInputVisible: alphaInputCheckBox.checked
                alphaEnabled: alphaCheckBox.checked
                ringMode: rinCheckBox.checked

                color: "white"
            }

            showcase: [
                CheckBox {
                    id: moreBtnCheckBox
                    text: qsTr("moreButtonVisible")
                },
                CheckBox {
                    id: colorSliderCheckBox
                    text: qsTr("colorSliderVisible")
                    checked: true
                },
                CheckBox {
                    id: colorChannelCheckBox
                    text: qsTr("colorChannelInputVisible")
                    checked: true
                },
                CheckBox {
                    id: hexCheckBox
                    text: qsTr("HexInputVisible")
                    checked: true
                },
                CheckBox {
                    id: alphaCheckBox
                    text: qsTr("alphaEnabled")
                },
                CheckBox {
                    id: alphaSliderCheckBox
                    text: qsTr("alphaSliderVisible")
                    checked: true
                },
                CheckBox {
                    id: alphaInputCheckBox
                    text: qsTr("AlphaInputVisible")
                    checked: true
                },
                Text {
                    text: qsTr("Colorspectrum shape")
                },
                Column {
                    RadioButton {
                        text: qsTr("Box")
                        checked: true
                    }
                    RadioButton {
                        id: rinCheckBox  // rin (((
                        text: qsTr("Ring")
                    }
                },
                Text {
                    text: qsTr("ColorPicker applied on a Rectangle")
                },
                Rectangle {
                    width: 250
                    height: 100
                    color: picker.color
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("DropDownColorPicker")
        }
        ControlShowcase {
            width: parent.width
            showcaseWidth: 300

            DropDownColorPicker {
                // picker
                moreVisible: moreBtnCheckBox.checked
                colorSliderVisible: colorSliderCheckBox.checked
                colorChannelInputVisible: colorChannelCheckBox.checked
                hexInputVisible: hexCheckBox.checked
                alphaSliderVisible: alphaSliderCheckBox.checked
                alphaInputVisible: alphaInputCheckBox.checked
                alphaEnabled: alphaCheckBox.checked
                ringMode: rinCheckBox.checked

                // self
                textVisible: textCheckBox.checked
                hexText: hexTextCheckBox.checked

                color: "white"
            }

            showcase: [
                CheckBox {
                    id: textCheckBox
                    text: qsTr("textVisible")
                },
                CheckBox {
                    id: hexTextCheckBox
                    text: qsTr("hexText")
                }
            ]
        }
    }
}
