import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import Qt5Compat.GraphicalEffects  // 图形库
import FluentQML
import "../assets"
import "../components"

FluentPage {
    id: page
    // title: "test"
    horizontalPadding: 0
    wrapperWidth: width - 42*2

    property string query: ""

    header: Frame {
        width: parent.width
        height: 48

        RowLayout {
            anchors.fill: parent

            SelectorBar {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                SelectorBarItem {
                    text: qsTr("All")
                    checked: true
                }
            }
        }
    }

    // Content / 内容 //
    Grid {
        Layout.fillWidth: true
        columns: Math.floor(width / (360 + 6)) // 自动算列数
        rowSpacing: 12
        columnSpacing: 12
        layoutDirection: GridLayout.LeftToRight

        Repeater {
            model: ItemData.getItemsByTitle(query)
            delegate: ControlClip { }
        }
    }
}
