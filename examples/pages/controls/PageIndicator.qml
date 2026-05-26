import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import FluentQML as Fluent
import "../../components"

ControlPage {
    title: qsTr("PageIndicator")
    badgeText: qsTr("New")
    badgeSeverity: Severity.Success

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr(
            "A PageIndicator lets users navigate through a paginated collection when page numbers do not need to be visually known."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("PageIndicator integrated with a SwipeView")
        }

        Frame {
            width: parent.width
            height: 360

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Fluent.SwipeView {
                    id: view
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Rectangle {
                        color: Theme.currentTheme.colors.subtleColor

                        Text {
                            anchors.centerIn: parent
                            typography: Typography.Title
                            text: qsTr("Home")
                        }
                    }
                    Rectangle {
                        color: Theme.currentTheme.colors.subtleSecondaryColor

                        Text {
                            anchors.centerIn: parent
                            typography: Typography.Title
                            text: qsTr("Discover")
                        }
                    }
                    Rectangle {
                        color: Theme.currentTheme.colors.controlColor

                        Text {
                            anchors.centerIn: parent
                            typography: Typography.Title
                            text: qsTr("Activity")
                        }
                    }
                }

                Fluent.PageIndicator {
                    id: pageIndicator
                    Layout.alignment: Qt.AlignHCenter
                    interactive: true
                    count: view.count
                    carel: true
                    onCurrentIndexChanged: {
                        if (view.currentIndex !== currentIndex) {
                            view.currentIndex = currentIndex
                        }
                    }

                    Connections {
                        target: view

                        function onCurrentIndexChanged() {
                            if (pageIndicator.currentIndex !== view.currentIndex) {
                                pageIndicator.currentIndex = view.currentIndex
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
            text: qsTr("PageIndicator with switch to change its button visibility")
        }

        ControlShowcase {
            width: parent.width
            showcaseWidth: 112

            Fluent.PageIndicator {
                count: 8
                interactive: true
                carel: carelSwitch.checked
            }

            showcase: [
                Text {
                    text: qsTr("Carel")
                },
                Switch {
                    id: carelSwitch
                    checked: true
                }
            ]
        }
    }
}
