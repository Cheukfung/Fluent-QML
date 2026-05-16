import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("SelectorBar")
    badgeText: qsTr("Extra")
    badgeSeverity: Severity.Success

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr("SelectorBar is used to modify the content shown by allowing users to select and switch between a small, finite set of data.")
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A Basic SelectorBar")
        }
        Frame {
            width: parent.width
            SelectorBar {
                SelectorBarItem {
                    text: qsTr("Recent")
                    icon.name: "ic_fluent_clock_20_regular"
                }
                SelectorBarItem {
                    text: qsTr("Shared")
                    icon.name: "ic_fluent_share_20_regular"
                }
                SelectorBarItem {
                    text: qsTr("Favorites")
                    icon.name: "ic_fluent_star_20_regular"
                }
                // model: [
                //     { text: "Recent", icon: "ic_fluent_clock_20_regular"},
                //     { text: "Shared", icon: "ic_fluent_share_20_regular"},
                //     { text: "Favorites", icon: "ic_fluent_star_20_regular"},
                // ]
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("SelectorBar with Loader")
        }
        Frame {
            width: parent.width
            Column {
                width: parent.width
                spacing: 0
                SelectorBar {
                    id: selectorBar
                    currentIndex: 0

                    Repeater {
                        id: rep
                        model: [
                            { text: "Page1", page: page1 },
                            { text: "Page2", page: page2 },
                            { text: "Page3", page: page3 },
                        ]
                        SelectorBarItem {
                            text: modelData.text
                        }
                    }
                }
                Loader {
                    width: parent.width
                    height: 400
                    sourceComponent: rep.model[selectorBar.currentIndex].page
                }
            }
        }
    }

    // 展示页面
    Component {
        id: page1

        SamplePage {
            title: qsTr("Sample Page 1")
        }
    }

    Component {
        id: page2

        FluentPage {
            title: qsTr("Sample Page 2")
            GridLayout {
                Layout.fillWidth: true
                height: 400
                columns: 2
                rowSpacing: 12
                columnSpacing: 12

                Rectangle {
                    color: Theme.currentTheme.colors.primaryColor
                    width: 150
                    height: 200
                    Layout.rowSpan: 2
                }

                Text {
                    typography: Typography.Title
                    Layout.fillWidth: true
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
                }
                Text {
                    typography: Typography.Body
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "Abydos High School, the longest running school in Kivotos, formerly thriving and boasting incredible financial and military power, before the unnatural and unfortunate desertification struck. Nowadays, most of its buildings have been covered in sand and ruins, leaving behind only an annex which seems to be the very last remains of the school."
                }
            }
        }
    }

    Component {
        id: page3

        SamplePage {
            title: qsTr("Sample Page 3")
            primaryColor: "#e9967a"
            gridColor: "#f08080"
            gridSecondaryColor: "#cd5c5c"
        }
    }

    Component {
        id: page4

        FluentPage {
            title: qsTr("Settings")
        }
    }
}
