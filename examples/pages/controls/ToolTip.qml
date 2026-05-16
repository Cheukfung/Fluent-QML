import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("ToolTip")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "A ToolTip shows more information about a UI element. You might show information about what the element " +
            "does, or what the user should do. The ToolTip is shown when a suer hovers over or presses and holds the " +
            "UI element."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A button with a simple ToolTip")
        }
        Frame {
            width: parent.width
            Button {
                text: qsTr("Button with a simple ToolTip")

                ToolTip {
                    text: qsTr("Simple ToolTip")
                    visible: parent.hovered
                    delay: 250 // Delay before showing the tooltip
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A Text with an offset ToolTip.")
        }
        Frame {
            width: parent.width
            Text {
                text: qsTr("Text with an offset ToolTip.")

                HoverHandler {
                    id: hoverHandler
                }

                ToolTip {
                    y: 80
                    text: qsTr("Offset ToolTip")
                    visible: hoverHandler.hovered
                    delay: 250
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("An Image with a ToolTip.")
        }
        Frame {
            width: parent.width
            Row {
                Image {
                    source: "../../assets/129201829_p0.png"
                    width: 300
                    height: 400
                    fillMode: Image.PreserveAspectCrop

                    HoverHandler {
                        id: imageHoverHandler
                    }

                    ToolTip {
                        text: qsTr("ToolTip")
                        visible: imageHoverHandler.hovered
                        delay: 250
                    }
                }
            }
        }
    }
}
