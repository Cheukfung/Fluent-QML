import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    id: page
    title: qsTr("CommandBar")

    Action {
        id: settingsAction
        icon.name: "ic_fluent_settings_20_regular"
        text: qsTr("Settings")
        shortcut: "Ctrl+I"
    }

    Action {
        id: printAction
        icon.name: "ic_fluent_print_20_regular"
        text: qsTr("Print")
        shortcut: "Ctrl+P"
    }

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr("CommandBar presents app actions in a compact horizontal row and moves extra commands into an overflow menu.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Command bar")
        }

        Frame {
            width: parent.width
            height: 96
            hoverable: false

            CommandBar {
                id: commandBar
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(parent.width - 40, suitableWidth())
                toolButtonStyle: Qt.ToolButtonTextBesideIcon
                hiddenActions: [settingsAction]

                CommandButton {
                    icon.name: "ic_fluent_add_20_regular"
                    text: qsTr("Add")
                }
                CommandButton {
                    icon.name: "ic_fluent_arrow_rotate_clockwise_20_regular"
                    text: qsTr("Rotate")
                }
                CommandButton {
                    icon.name: "ic_fluent_zoom_in_20_regular"
                    text: qsTr("Zoom in")
                }
                CommandButton {
                    icon.name: "ic_fluent_zoom_out_20_regular"
                    text: qsTr("Zoom out")
                }
                CommandSeparator { }
                CommandButton {
                    checkable: true
                    icon.name: "ic_fluent_edit_20_regular"
                    text: qsTr("Edit")
                }
                CommandButton {
                    icon.name: "ic_fluent_info_20_regular"
                    text: qsTr("Info")
                }
                CommandButton {
                    icon.name: "ic_fluent_delete_20_regular"
                    text: qsTr("Delete")
                }
                CommandButton {
                    icon.name: "ic_fluent_share_20_regular"
                    text: qsTr("Share")
                }
                DropDownToolButton {
                    icon.name: "ic_fluent_arrow_sort_20_regular"
                    text: qsTr("Sort")

                    MenuItemGroup {
                        id: sortFieldGroup
                    }
                    MenuItem {
                        text: qsTr("Create Date")
                        group: sortFieldGroup
                    }
                    MenuItem {
                        text: qsTr("Shooting Date")
                        checked: true
                        group: sortFieldGroup
                    }
                    MenuItem {
                        text: qsTr("Modified time")
                        group: sortFieldGroup
                    }
                    MenuItem {
                        text: qsTr("Name")
                        group: sortFieldGroup
                    }
                    MenuSeparator { }
                    MenuItemGroup {
                        id: sortDirectionGroup
                    }
                    MenuItem {
                        icon.name: "ic_fluent_arrow_up_20_regular"
                        text: qsTr("Ascending")
                        checked: true
                        group: sortDirectionGroup
                    }
                    MenuItem {
                        icon.name: "ic_fluent_arrow_down_20_regular"
                        text: qsTr("Descending")
                        group: sortDirectionGroup
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
            text: qsTr("Overflow menu")
        }

        ControlShowcase {
            width: parent.width
            height: 108

            CommandBar {
                width: overflowWidthSlider.value
                anchors.verticalCenter: parent.verticalCenter
                toolButtonStyle: Qt.ToolButtonTextBesideIcon
                hiddenActions: [settingsAction]

                CommandButton {
                    icon.name: "ic_fluent_add_20_regular"
                    text: qsTr("Add")
                }
                CommandButton {
                    icon.name: "ic_fluent_arrow_rotate_clockwise_20_regular"
                    text: qsTr("Rotate")
                }
                CommandButton {
                    icon.name: "ic_fluent_zoom_in_20_regular"
                    text: qsTr("Zoom in")
                }
                CommandButton {
                    icon.name: "ic_fluent_zoom_out_20_regular"
                    text: qsTr("Zoom out")
                }
                CommandSeparator { }
                CommandButton {
                    icon.name: "ic_fluent_edit_20_regular"
                    text: qsTr("Edit")
                }
                CommandButton {
                    icon.name: "ic_fluent_info_20_regular"
                    text: qsTr("Info")
                }
                CommandButton {
                    icon.name: "ic_fluent_delete_20_regular"
                    text: qsTr("Delete")
                }
                CommandButton {
                    icon.name: "ic_fluent_share_20_regular"
                    text: qsTr("Share")
                }

            }

            showcase: [
                Text {
                    typography: Typography.Caption
                    text: qsTr("Width")
                },
                Slider {
                    id: overflowWidthSlider
                    width: 160
                    from: 140
                    to: 520
                    value: 300
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Command bar flyout")
        }

        Frame {
            width: parent.width
            height: 318
            hoverable: false

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    typography: Typography.Body
                    text: qsTr("Click the image to open a command bar flyout.")
                }

                Image {
                    id: imageLabel
                    width: 350
                    height: 210
                    source: Qt.resolvedUrl("../../assets/129201829_p0.png")
                    fillMode: Image.PreserveAspectCrop
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: commandFlyout.visible ? commandFlyout.close() : commandFlyout.open()
                    }

                    Popup {
                        id: commandFlyout
                        padding: 0
                        modal: false
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                        x: imageLabel.width + 12
                        y: Math.round((imageLabel.height - commandFlyoutView.height) / 2)
                        width: commandFlyoutView.width
                        height: commandFlyoutView.height
                        implicitWidth: commandFlyoutView.implicitWidth
                        implicitHeight: commandFlyoutView.implicitHeight
                        background: Item {}

                        CommandBarView {
                            id: commandFlyoutView
                            hiddenActions: [printAction, settingsAction]

                            CommandButton {
                                icon.name: "ic_fluent_share_20_regular"
                                text: qsTr("Share")
                            }
                            CommandButton {
                                icon.name: "ic_fluent_save_20_regular"
                                text: qsTr("Save")
                            }
                            CommandButton {
                                icon.name: "ic_fluent_heart_20_regular"
                                text: qsTr("Favorite")
                            }
                            CommandButton {
                                icon.name: "ic_fluent_delete_20_regular"
                                text: qsTr("Delete")
                            }
                        }
                    }
                }
            }
        }
    }
}
