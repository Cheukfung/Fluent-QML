import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    id: page
    title: "MenuBar"

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr(
            "The MenuBar simplifies the creation of basic application by providing a set of menus at the top of the app or window. "
        )
    }


    Column {
        Layout.fillWidth: true
        spacing: 4
        Text {
            typography: Typography.BodyStrong
                text: "A simple MenuBar"
        }

        Frame {
            width: parent.width
            MenuBar {
                Menu {
                    title: qsTr("File")
                    MenuItem {
                        text: qsTr("New")
                    }
                    MenuItem {
                        text: qsTr("Open")
                    }
                    MenuItem {
                        text: qsTr("Save")
                    }
                    MenuItem {
                        text: qsTr("Exit")
                    }
                }
                Menu {
                    title: qsTr("Edit")
                    MenuItem {
                        text: qsTr("Undo")
                    }
                    MenuItem {
                        text: qsTr("Cut")
                    }
                    MenuItem {
                        text: qsTr("Copy")
                    }
                    MenuItem {
                        text: qsTr("Paste")
                    }
                }
                Menu {
                    title: qsTr("Help")
                    MenuItem {
                        text: qsTr("About")
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
                text: qsTr("MenuBar with keyboard accelerators.")
        }

        Frame {
            width: parent.width
            MenuBar {
                Menu {
                    title: qsTr("File")
                    Action {
                        text: qsTr("New")
                        shortcut: "Ctrl+N"
                    }
                    Action {
                        text: qsTr("Open")
                        shortcut: "Ctrl+O"
                    }
                    Action {
                        text: qsTr("Save")
                        shortcut: "Ctrl+S"
                    }
                    Action {
                        text: qsTr("Exit")
                        shortcut: "Ctrl+E"
                    }
                }
                Menu {
                    title: qsTr("Edit")
                    Action {
                        text: qsTr("Undo")
                        shortcut: "Ctrl+Z"
                    }
                    Action {
                        text: qsTr("Cut")
                        shortcut: "Ctrl+X"
                    }
                    Action {
                        text: qsTr("Copy")
                        shortcut: "Ctrl+C"
                    }
                    Action {
                        text: qsTr("Paste")
                        shortcut: "Ctrl+V"
                    }
                }
                Menu {
                    title: qsTr("Help")
                    Action {
                        text: qsTr("About")
                        shortcut: "Ctrl+I"
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
                text: qsTr("MenuBar with submenus, separators, and checkable items")
        }

        Frame {
            width: parent.width
            MenuBar {
                Menu {
                    title: qsTr("File")
                    Menu {
                        title: qsTr("New")
                        MenuItem {
                            text: qsTr("Plain Text Document")
                        }
                        MenuItem {
                            text: qsTr("Rich Text Document")
                        }
                        MenuItem {
                            text: qsTr("Other Formats")
                        }
                    }
                    MenuItem {
                        text: qsTr("Open")
                    }
                    MenuItem {
                        text: qsTr("Save")
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr("Exit")
                    }
                }
                Menu {
                    title: qsTr("Edit")
                    MenuItem {
                        text: qsTr("Undo")

                    }
                    MenuItem {
                        text: qsTr("Cut")
                    }
                    MenuItem {
                        text: qsTr("Copy")
                    }
                    MenuItem {
                        text: qsTr("Paste")
                    }
                }
                Menu {
                    id: view
                    title: qsTr("View")
                    MenuItem {
                        text: qsTr("Output")
                    }
                    MenuSeparator {}

                    // 自定义menuitem组 / custom menuitem group like ButtonGroup //
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
                Menu {
                    title: qsTr("Help")
                    MenuItem {
                        text: qsTr("About")
                    }
                }
            }
        }
    }
}
