import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Flyout")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "A Flyout displays lightweight UI that is either information, or requires user interaction. " +
            "Unlike a Dialog, a Flyout can be light dismissed by clicking or tapping off of it. " +
            "Use it to collect input from the user, show more details about an item, or ask the user to confirm an action."
        )
    }


    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A button with a flyout")
        }
        Frame {
            width: parent.width

            Button {
                text: qsTr("Empty cart")
                onClicked: {
                    flyout.open()
                }

                Flyout {
                    id: flyout
                    Text {
                        text: qsTr("All items will be removed. Do you want to continue?")
                    }
                    buttonBox: [
                        Button {
                            text: qsTr("Yes, empty my cart")
                            onClicked: flyout.close()
                        }
                    ]
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Flyouts with different positions, and different contents")
        }
        Frame {
            width: parent.width

            Row {
                spacing: 8
                Button {
                    text: qsTr("Top flyout")
                    onClicked: {
                        flyoutTop.open()
                    }

                    Flyout {
                        id: flyoutTop

                        Image {
                            source: Qt.resolvedUrl("../../assets/banner.png")
                            fillMode: Image.PreserveAspectCrop
                            Layout.bottomMargin: 0

                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 150
                        }
                        Text {
                            text: qsTr("The flyout is on the Top")
                        }
                    }
                }
                Button {
                    text: qsTr("Bottom flyout")
                    onClicked: {
                        flyoutBottom.open()
                    }

                    Flyout {
                        id: flyoutBottom
                        position: Position.Bottom
                        text: qsTr("Do you want to continue?")
                        buttonBox: [
                            Button {
                                Layout.fillWidth: true
                                highlighted: true
                                text: qsTr("Continue")
                                onClicked: flyoutBottom.close()
                            },
                            Button {
                                Layout.fillWidth: true
                                text: qsTr("Cancel")
                                onClicked: flyoutBottom.close()
                            }
                        ]
                    }
                }
                Button {
                    text: qsTr("Left flyout")
                    onClicked: {
                        flyoutLeft.open()
                    }

                    Flyout {
                        id: flyoutLeft
                        position: Position.Left
                        text: qsTr("The flyout is on the Left")

                        Image {
                            source: Qt.resolvedUrl("../../assets/BA_Pic_Shiroko-chibi.png")
                            fillMode: Image.PreserveAspectCrop
                            Layout.bottomMargin: 0

                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 200
                        }
                    }
                }
                Button {
                    text: qsTr("Right flyout")
                    onClicked: {
                        flyoutRight.open()
                    }

                    Flyout {
                        id: flyoutRight
                        position: Position.Right
                        text: qsTr("The flyout is on the Right")
                    }
                }
            }
        }
    }
}
