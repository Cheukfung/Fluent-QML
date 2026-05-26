import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 2.15
import "../../themes"
import "../../components"

Item {
    id: root

    property var model: []
    property int currentIndex: model.length - 1
    property string textRole: "text"
    property string routeRole: "routeKey"
    property int itemHeight: 22
    property int spacing: 10

    readonly property int count: model ? model.length : 0
    implicitWidth: row.implicitWidth
    implicitHeight: itemHeight

    signal itemClicked(int index, var item)
    signal currentItemChanged(int index, var item)

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: row.implicitWidth
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Row {
            id: row
            height: root.itemHeight
            spacing: root.spacing

            Repeater {
                model: root.count

                Item {
                    height: root.itemHeight
                    width: label.implicitWidth + (modelData === 0 ? 0 : root.spacing * 2)

                    Icon {
                        id: chevron
                        x: 0
                        anchors.verticalCenter: parent.verticalCenter
                        size: 12
                        color: Theme.currentTheme.colors.textColor
                        opacity: 0.61
                        name: "ic_fluent_chevron_right_20_regular"
                        visible: modelData > 0
                    }

                    Text {
                        id: label
                        x: modelData === 0 ? 0 : root.spacing * 2
                        anchors.verticalCenter: parent.verticalCenter
                        typography: Typography.Body
                        text: root.itemText(modelData)
                        color: Theme.currentTheme.colors.textColor
                        opacity: breadcrumbMouse.pressed
                            ? (modelData === root.currentIndex ? 1 : 0.45)
                            : (modelData === root.currentIndex || breadcrumbMouse.containsMouse ? 1 : 0.61)
                    }

                    MouseArea {
                        id: breadcrumbMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activate(modelData)
                    }
                }
            }
        }
    }

    onCurrentIndexChanged: currentItemChanged(currentIndex, itemAt(currentIndex))

    function itemAt(index) {
        if (!model || index < 0 || index >= model.length) {
            return null
        }
        return model[index]
    }

    function itemText(index) {
        var item = itemAt(index)
        if (!item) {
            return ""
        }
        if (typeof item === "string") {
            return item
        }
        return item[root.textRole] !== undefined ? item[root.textRole] : ""
    }

    function itemRouteKey(index) {
        var item = itemAt(index)
        if (!item || typeof item === "string") {
            return ""
        }
        return item[root.routeRole] !== undefined ? item[root.routeRole] : ""
    }

    function addItem(routeKey, text) {
        var next = model ? model.slice() : []
        next.push({ routeKey: routeKey, text: text })
        model = next
        currentIndex = next.length - 1
    }

    function setItemText(routeKey, text) {
        if (!model) {
            return
        }

        var next = model.slice()
        for (var i = 0; i < next.length; ++i) {
            if (next[i][root.routeRole] === routeKey) {
                next[i][root.textRole] = text
                model = next
                return
            }
        }
    }

    function activate(index) {
        var item = itemAt(index)
        if (!item) {
            return
        }
        if (index < model.length - 1) {
            model = model.slice(0, index + 1)
        }
        currentIndex = index
        itemClicked(index, item)
    }
}
