import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Segmented")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "A common UI control to configure a view or setting."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple Segmented.")
        }
        ControlShowcase {
            width: parent.width

            Segmented {
                width: parent.width
                enabled: !segmentedSwitch.checked
                SegmentedItem {
                    icon.name: "ic_fluent_circle_20_regular"
                    text: qsTr("Item 1")
                }
                SegmentedItem {
                    icon.name: "ic_fluent_circle_20_regular"
                    text: qsTr("Item 2")
                }
                SegmentedItem {
                    width: 250
                    icon.name: "ic_fluent_circle_20_regular"
                    text: qsTr("Item 3 with a long label")
                }
            }

            Text {
                text: qsTr("Icon only")
            }

            Segmented {
                enabled: !segmentedSwitch.checked
                SegmentedItem {
                    icon.name: "ic_fluent_camera_20_regular"
                    ToolTip {
                        text: qsTr("Camera")
                        visible: parent.hovered
                    }
                }
                SegmentedItem {
                    icon.name: "ic_fluent_video_20_regular"
                    ToolTip {
                        text: qsTr("Video")
                        visible: parent.hovered
                    }
                }
                SegmentedItem {
                    icon.name: "ic_fluent_image_20_regular"
                    ToolTip {
                        text: qsTr("Image")
                        visible: parent.hovered
                    }
                }
            }

            showcase: [
                CheckBox {
                    id: segmentedSwitch
                    text: qsTr("Disable Segmented")
                }
            ]
        }
    }
}
