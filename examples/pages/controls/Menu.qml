import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    id: page
    title: "Menu"

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr(
            "A Menu displays lightweight UI that is light dismissed by clicking or tapping off of it." +
             "Use it to let the user choose from a contextual list of simple commands or options."
        )
    }


    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
                text: "A Menu with MenuItems and MenuSeparator."
        }
        Frame {
            width: parent.width
            height: 100
            Button {
                flat: true
                icon.name: "ic_fluent_arrow_sort_20_regular"
                width: 76
                height: 36
                text: qsTr("Sort")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: menu.open()

                Menu {
                    id: menu
                    MenuItem {
                        text: qsTr("By rating")
                    }
                    MenuItem {
                        text: qsTr("By match")
                    }
                    MenuItem {
                        text: qsTr("By distance")
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
                text: "A Menu with MenuItems and MenuSeparator."
        }
        Frame {
            width: parent.width
            Button {
                text: qsTr("Options")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: menuToggle.open()

                Menu {
                    id: menuToggle
                    MenuItem {
                        text: qsTr("Reset")
                    }
                    MenuSeparator {}
                    MenuItem {
                        checkable: true
                        checked: true
                        text: qsTr("Repeat")
                    }
                    MenuItem {
                        checkable: true
                        checked: true
                        text: qsTr("Shuffle")
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
                text: "A Menu with cascading Menus."
        }
        Frame {
            width: parent.width
            Button {
                text: qsTr("File Options")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: menuWithCascading.open()

                Menu {
                    id: menuWithCascading
                    MenuItem {
                        text: qsTr("Open")
                    }
                    Menu {
                        title: qsTr("Send to")
                        MenuItem {
                            text: qsTr("Bluetooth")
                        }
                        MenuItem {
                            text: qsTr("Desktop (shortcut)")
                        }
                        Menu {
                            title: qsTr("Compressed file")
                            MenuItem {
                                text: qsTr("Compress and email")
                            }
                            MenuItem {
                                text: qsTr("Compress to .7z")
                            }
                            MenuItem {
                                text: qsTr("Compress to .zip")
                            }
                        }
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
                text: "A Menu with icons."
        }
        Frame {
            width: parent.width
            Button {
                text: qsTr("Edit Options")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: menuWithIcons.open()

                Menu {
                    id: menuWithIcons
                    MenuItem {
                        icon.name: "ic_fluent_share_20_regular"
                        text: qsTr("Share")
                    }
                    MenuItem {
                        icon.name: "ic_fluent_copy_20_regular"
                        text: qsTr("Copy")
                    }
                    MenuItem {
                        icon.name: "ic_fluent_delete_20_regular"
                        text: qsTr("Delete")
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr("Rename")
                    }
                    MenuItem {
                        text: qsTr("Select")
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
                text: "A Menu with Keyboard Accelerators."
        }
        Frame {
            width: parent.width
            Button {
                text: qsTr("Edit Options")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: menuWithIconsAndShortcuts.open()

                Menu {
                    id: menuWithIconsAndShortcuts
                    Action {
                        icon.name: "ic_fluent_share_20_regular"
                        text: qsTr("Share")
                        shortcut: "Ctrl+S"
                    }
                    Action {
                        icon.name: "ic_fluent_copy_20_regular"
                        text: qsTr("Copy")
                        shortcut: "Ctrl+C"
                    }
                    Action {
                        icon.name: "ic_fluent_delete_20_regular"
                        text: qsTr("Delete")
                        shortcut: "Delete"
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr("Rename")
                    }
                    MenuItem {
                        text: qsTr("Select")
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
                text: "A Menu with radio menus and MenuItemGroup"
        }
        Frame {
            width: parent.width
            Button {
                text: qsTr("Options")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: menuWithRadio.open()

                Menu {
                    id: menuWithRadio
                    MenuItemGroup {
                        id: orientationGroup
                    }
                    MenuItem {
                        text: qsTr("Landscape")
                        group: orientationGroup
                    }
                    MenuItem {
                        text: qsTr("Portrait")
                        checked: true
                        group: orientationGroup
                    }

                    MenuSeparator {}
                    MenuItemGroup {
                        id: iconSizeGroup
                    }
                    MenuItem {
                        text: qsTr("Small icons")
                        group: iconSizeGroup
                    }
                    MenuItem {
                        text: qsTr("Medium icons")
                        group: iconSizeGroup
                        checked: true
                    }
                    MenuItem {
                        text: qsTr("Large icons")
                        group: iconSizeGroup
                    }
                }
            }
        }
    }
}
