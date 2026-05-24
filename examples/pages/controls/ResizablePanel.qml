import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("ResizablePanel")
    badgeText: qsTr("New")
    badgeSeverity: Severity.Success

    Text {
        Layout.fillWidth: true
        text: qsTr(
            "ResizablePanel arranges child items in a horizontal or vertical split view. Drag the divider to resize panes, and use SplitView attached properties to define minimum and preferred sizes."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A horizontal ResizablePanel")
        }

        ControlShowcase {
            width: parent.width

            ResizablePanel {
                width: Math.min(parent.width, 720)
                height: 180
                orientation: orientationComboBox.currentIndex === 0 ? Qt.Horizontal : Qt.Vertical

                Frame {
                    SplitView.minimumWidth: 160
                    SplitView.minimumHeight: 90
                    SplitView.preferredWidth: 220
                    SplitView.preferredHeight: 110

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        Text {
                            typography: Typography.BodyStrong
                            text: qsTr("Navigation")
                        }
                        Text {
                            Layout.fillWidth: true
                            color: Theme.currentTheme.colors.textSecondaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("Use this pane for a file tree, route list, or sidebar filters.")
                        }
                    }
                }

                Frame {
                    SplitView.fillWidth: true
                    SplitView.fillHeight: true
                    SplitView.minimumWidth: 220
                    SplitView.minimumHeight: 120

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        Text {
                            typography: Typography.BodyStrong
                            text: qsTr("Content")
                        }
                        Text {
                            Layout.fillWidth: true
                            color: Theme.currentTheme.colors.textSecondaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("This pane fills the remaining space and keeps a minimum interactive area.")
                        }
                    }
                }
            }

            showcase: [
                Text {
                    text: qsTr("Orientation")
                },
                ComboBox {
                    id: orientationComboBox
                    model: ["Horizontal", "Vertical"]
                }
            ]
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Nested panels for editor-style layouts")
        }

        Frame {
            width: parent.width
            height: 360

            ResizablePanel {
                anchors.fill: parent

                Frame {
                    SplitView.minimumWidth: 150
                    SplitView.preferredWidth: 200

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Explorer")
                    }
                }

                ResizablePanel {
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 260
                    orientation: Qt.Vertical

                    Frame {
                        SplitView.fillHeight: true
                        SplitView.minimumHeight: 80

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Editor")
                        }
                    }

                    Frame {
                        SplitView.minimumHeight: 64
                        SplitView.preferredHeight: 120

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Output")
                        }
                    }
                }
            }
        }
    }
}
