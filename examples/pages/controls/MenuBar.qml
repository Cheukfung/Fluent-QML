import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML as F
import "../../components"

ControlPage {
    id: page
    title: "MenuBar"

    F.Text {
        Layout.fillWidth: true
        typography: F.Typography.Body
        text: qsTr(
            "The MenuBar simplifies the creation of basic application by providing a set of menus at the top of the app or window. "
        )
    }


    Column {
        Layout.fillWidth: true
        spacing: 4
        F.Text {
            typography: F.Typography.BodyStrong
                text: "A simple MenuBar"
        }

        F.Frame {
            width: parent.width
            height: 76
            F.MenuBar {
                anchors.verticalCenter: parent.verticalCenter
                F.Menu {
                    title: qsTr("File")
                    F.MenuItem {
                        text: qsTr("New")
                    }
                    F.MenuItem {
                        text: qsTr("Open")
                    }
                    F.MenuItem {
                        text: qsTr("Save")
                    }
                    F.MenuItem {
                        text: qsTr("Exit")
                    }
                }
                F.Menu {
                    title: qsTr("Edit")
                    F.MenuItem {
                        text: qsTr("Undo")
                    }
                    F.MenuItem {
                        text: qsTr("Cut")
                    }
                    F.MenuItem {
                        text: qsTr("Copy")
                    }
                    F.MenuItem {
                        text: qsTr("Paste")
                    }
                }
                F.Menu {
                    title: qsTr("Help")
                    F.MenuItem {
                        text: qsTr("About")
                    }
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4
        F.Text {
            typography: F.Typography.BodyStrong
                text: qsTr("MenuBar with keyboard accelerators.")
        }

        F.Frame {
            width: parent.width
            height: 76
            F.MenuBar {
                anchors.verticalCenter: parent.verticalCenter
                F.Menu {
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
                F.Menu {
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
                F.Menu {
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
        F.Text {
            typography: F.Typography.BodyStrong
                text: qsTr("MenuBar with submenus, separators, and checkable items")
        }

        F.Frame {
            width: parent.width
            height: 76
            F.MenuBar {
                anchors.verticalCenter: parent.verticalCenter
                F.Menu {
                    title: qsTr("File")
                    F.Menu {
                        title: qsTr("New")
                        F.MenuItem {
                            text: qsTr("Plain Text Document")
                        }
                        F.MenuItem {
                            text: qsTr("Rich Text Document")
                        }
                        F.MenuItem {
                            text: qsTr("Other Formats")
                        }
                    }
                    F.MenuItem {
                        text: qsTr("Open")
                    }
                    F.MenuItem {
                        text: qsTr("Save")
                    }
                    F.MenuSeparator {}
                    F.MenuItem {
                        text: qsTr("Exit")
                    }
                }
                F.Menu {
                    title: qsTr("Edit")
                    F.MenuItem {
                        text: qsTr("Undo")

                    }
                    F.MenuItem {
                        text: qsTr("Cut")
                    }
                    F.MenuItem {
                        text: qsTr("Copy")
                    }
                    F.MenuItem {
                        text: qsTr("Paste")
                    }
                }
                F.Menu {
                    id: view
                    title: qsTr("View")
                    F.MenuItem {
                        text: qsTr("Output")
                    }
                    F.MenuSeparator {}

                    // 自定义menuitem组 / custom menuitem group like ButtonGroup //
                    F.MenuItemGroup {
                        id: orientationGroup
                    }
                    F.MenuItem {
                        text: qsTr("Landscape")
                        group: orientationGroup
                    }
                    F.MenuItem {
                        text: qsTr("Portrait")
                        checked: true
                        group: orientationGroup
                    }

                    F.MenuSeparator {}
                    F.MenuItemGroup {
                        id: iconSizeGroup
                    }
                    F.MenuItem {
                        text: qsTr("Small icons")
                        group: iconSizeGroup
                    }
                    F.MenuItem {
                        text: qsTr("Medium icons")
                        group: iconSizeGroup
                        checked: true
                    }
                    F.MenuItem {
                        text: qsTr("Large icons")
                        group: iconSizeGroup
                    }
                }
                F.Menu {
                    title: qsTr("Help")
                    F.MenuItem {
                        text: qsTr("About")
                    }
                }
            }
        }
    }
}
