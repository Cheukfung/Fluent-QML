import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML as Fluent
import FluentQML
import "../../components"

ControlPage {
    id: page
    title: "TreeView"
    badgeText: qsTr("Experimental")
    badgeSeverity: Severity.Warning

    property var projectNodes: [
        {
            text: qsTr("FluentQML"),
            expanded: true,
            children: [
                {
                    text: qsTr("components"),
                    expanded: true,
                    children: [
                        { text: qsTr("BasicInput") },
                        { text: qsTr("ListAndCollections") },
                        { text: qsTr("Navigation") }
                    ]
                },
                {
                    text: qsTr("themes"),
                    children: [
                        { text: qsTr("light.qml") },
                        { text: qsTr("dark.qml") }
                    ]
                },
                { text: qsTr("qmldir") }
            ]
        },
        {
            text: qsTr("examples"),
            children: [
                { text: qsTr("gallery.qml") },
                { text: qsTr("pages") }
            ]
        }
    ]

    property var taskNodes: [
        {
            text: qsTr("Release checklist"),
            checked: true,
            expanded: true,
            children: [
                { text: qsTr("Update component exports"), checked: true },
                { text: qsTr("Add gallery sample"), checked: true },
                { text: qsTr("Run QML smoke test"), checked: false }
            ]
        },
        {
            text: qsTr("Documentation"),
            checked: false,
            expanded: true,
            children: [
                { text: qsTr("API usage"), checked: false },
                { text: qsTr("Screenshots"), checked: false }
            ]
        }
    ]

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr("TreeView displays hierarchical data with expandable rows.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Basic TreeView")
        }

        Frame {
            width: parent.width
            height: basicTree.height + topPadding + bottomPadding

            Fluent.TreeView {
                id: basicTree
                width: parent.width
                height: 260
                model: page.projectNodes
                currentIndex: 0
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("TreeView with CheckBox")
        }

        Frame {
            width: parent.width
            height: checkableTree.height + topPadding + bottomPadding

            Fluent.CheckableTreeView {
                id: checkableTree
                width: parent.width
                height: 260
                model: page.taskNodes
                currentIndex: 0
            }
        }
    }
}
