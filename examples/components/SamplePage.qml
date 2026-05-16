import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import Qt5Compat.GraphicalEffects  // 图形库
import FluentQML
import "../assets"
import "../components"

FluentPage {
    title: "Sample Page"
    horizontalPadding: 0
    wrapperWidth: width - 42

    property color primaryColor: Theme.currentTheme.colors.primaryColor
    property color gridColor: "#d3d3d3"
    property color gridSecondaryColor: "#a9a9a9"

    // Content / 内容 //
    GridLayout {
        Layout.fillWidth: true
        height: 400
        columns: 3
        rowSpacing: 12
        columnSpacing: 12

        Rectangle {
            color: primaryColor
            width: 250
            height: 320
            Layout.rowSpan: 2
        }

        Repeater {
            model: 4
            delegate: Rectangle {
                color: index % 3 === 0 ? gridSecondaryColor : gridColor
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
