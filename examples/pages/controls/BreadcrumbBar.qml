import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    id: page
    title: "BreadcrumbBar"
    badgeText: qsTr("New")
    badgeSeverity: Severity.Success

    property var folders: [
        { routeKey: "home", text: qsTr("Home") },
        { routeKey: "documents", text: qsTr("Documents") },
        { routeKey: "projects", text: qsTr("Projects") },
        { routeKey: "fluentqml", text: qsTr("FluentQML") }
    ]

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr("BreadcrumbBar shows the path to the current location and lets users jump back to a parent level.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A basic BreadcrumbBar")
        }

        ControlShowcase {
            width: parent.width

            Column {
                width: parent.width
                spacing: 12

                BreadcrumbBar {
                    id: breadcrumb
                    width: parent.width
                    model: page.folders
                    onItemClicked: function(index, item) {
                        selectedPath.text = qsTr("Selected: ") + item.text
                    }
                }

                Text {
                    id: selectedPath
                    typography: Typography.Body
                    text: qsTr("Selected: FluentQML")
                }
            }

            showcase: [
                Button {
                    text: qsTr("Add folder")
                    onClicked: breadcrumb.addItem("sample" + breadcrumb.count, qsTr("Sample ") + breadcrumb.count)
                },
                Button {
                    text: qsTr("Go home")
                    onClicked: breadcrumb.activate(0)
                }
            ]
        }
    }
}
