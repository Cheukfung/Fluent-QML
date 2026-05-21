import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 2.15
import Qt5Compat.GraphicalEffects
import "../../themes"
import "../../components"

Item {
    id: root
    clip: false

    property alias model: tableView.model
    property alias delegate: tableView.delegate
    property alias contentX: tableView.contentX
    property alias contentY: tableView.contentY
    readonly property alias rows: tableView.rows
    readonly property alias columns: tableView.columns

    property var columnDefinitions: []
    property int defaultColumnWidth: 160
    property int minimumColumnWidth: 96
    property int rowHeight: 38
    property int headerHeight: 34
    property int borderRadius: 8
    property bool borderVisible: true
    property bool showHeader: columnDefinitions.length > 0
    property bool showGridLines: false
    property bool showRowSeparators: false
    property bool alternatingRowColors: true
    property bool selectable: true
    property int selectedRow: -1
    property int selectedColumn: -1
    property int hoveredRow: -1
    property int pendingHoverClearRow: -1
    property int pressedRow: -1
    property bool editable: true
    property int editingRow: -1
    property int editingColumn: -1
    property int sortColumn: -1
    property int sortOrder: Qt.AscendingOrder
    readonly property int headerColumnCount: Math.max(0, columnDefinitions.length > 0 ? columnDefinitions.length : tableView.columns)
    readonly property int contentInset: borderVisible ? 1 : 0
    readonly property color borderColor: Theme.currentTheme.isDark
        ? Qt.rgba(1, 1, 1, 21 / 255)
        : Qt.rgba(0, 0, 0, 15 / 255)
    readonly property color headerColor: Theme.currentTheme.colors.backgroundColor

    signal cellClicked(int row, int column)
    signal cellEdited(int row, int column, string role, var value)
    signal headerClicked(int column)
    signal sortRequested(int column, string role, int order)

    Rectangle {
        anchors.fill: parent
        radius: root.borderRadius
        color: "transparent"
        border.width: root.borderVisible ? 1 : 0
        border.color: root.borderColor
        visible: root.borderVisible
        z: 10
    }

    Item {
        id: clippedContent
        anchors.fill: parent
        anchors.margins: root.contentInset
        layer.enabled: root.borderRadius > 0
        layer.smooth: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: clippedContent.width
                height: clippedContent.height
                radius: Math.max(0, root.borderRadius - root.contentInset)
            }
        }

        TableView {
            id: tableView
            anchors.fill: parent
            clip: true
            topMargin: root.showHeader ? root.headerHeight : 0
            rowHeightProvider: function(row) {
                return root.rowHeight
            }
            columnWidthProvider: function(column) {
                var definition = root.columnDefinition(column)
                if (!definition) {
                    return root.defaultColumnWidth
                }

                var width = definition.width !== undefined ? definition.width : root.defaultColumnWidth
                var minimum = definition.minimumWidth !== undefined ? definition.minimumWidth : root.minimumColumnWidth
                var maximum = definition.maximumWidth !== undefined ? definition.maximumWidth : Number.MAX_VALUE
                return Math.max(minimum, Math.min(width, maximum))
            }

            delegate: defaultDelegate

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        Item {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.headerHeight
            z: 100
            visible: root.showHeader
            clip: true

            Rectangle {
                anchors.fill: parent
                color: root.headerColor
            }

            Repeater {
                model: root.headerColumnCount

                Rectangle {
                    x: root.columnOffset(index) - tableView.contentX
                    width: root.columnWidthProvider(index)
                    height: root.headerHeight
                    color: headerMouse.containsMouse
                        ? Theme.currentTheme.colors.controlSecondaryColor
                        : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Item {
                            Layout.fillWidth: true
                            visible: sortIcon.visible
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            typography: Typography.Body
                            targetColor: Theme.currentTheme.isDark
                                ? Qt.rgba(203 / 255, 203 / 255, 203 / 255, 1)
                                : Qt.rgba(96 / 255, 96 / 255, 96 / 255, 1)
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            text: root.columnTitle(index)
                        }

                        Icon {
                            id: sortIcon
                            Layout.alignment: Qt.AlignVCenter
                            size: 14
                            color: Theme.currentTheme.colors.textSecondaryColor
                            visible: root.sortColumn === index
                            name: root.sortOrder === Qt.AscendingOrder
                                ? "ic_fluent_arrow_sort_up_20_regular"
                                : "ic_fluent_arrow_sort_down_20_regular"
                        }
                    }

                    MouseArea {
                        id: headerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activateHeader(index)
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: root.borderColor
                        visible: !root.isLastColumn(index)
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Theme.currentTheme.appearance.borderWidth
                color: root.borderColor
            }
        }
    }

    Timer {
        id: hoverClearTimer
        interval: 30
        repeat: false
        onTriggered: {
            if (root.hoveredRow === root.pendingHoverClearRow) {
                root.hoveredRow = -1
            }
            root.pendingHoverClearRow = -1
        }
    }

    function columnDefinition(column) {
        if (column < 0 || column >= root.columnDefinitions.length) {
            return null
        }
        return root.columnDefinitions[column]
    }

    function columnTitle(column) {
        var definition = root.columnDefinition(column)
        if (!definition) {
            return ""
        }
        return definition.title !== undefined ? definition.title : ""
    }

    function columnRole(column) {
        var definition = root.columnDefinition(column)
        if (!definition) {
            return ""
        }
        return definition.role !== undefined ? definition.role : ""
    }

    function columnAlignment(column) {
        var definition = root.columnDefinition(column)
        if (!definition || definition.alignment === undefined) {
            return Qt.AlignVCenter | Qt.AlignLeft
        }
        return Qt.AlignVCenter | definition.alignment
    }

    function columnOffset(column) {
        var offset = 0
        for (var i = 0; i < column; ++i) {
            offset += root.columnWidthProvider(i)
        }
        return offset
    }

    function columnWidthProvider(column) {
        return tableView.columnWidthProvider(column)
    }

    function isLastColumn(column) {
        return column === Math.max(0, headerColumnCount - 1)
    }

    function cellText(cellModel, column) {
        var role = root.columnRole(column)
        if (role.length > 0 && cellModel[role] !== undefined) {
            return cellModel[role]
        }
        if (cellModel.display !== undefined) {
            return cellModel.display
        }
        return ""
    }

    function selectCell(row, column) {
        if (!root.selectable) {
            return
        }
        root.selectedRow = row
        root.selectedColumn = column
    }

    function isEditing(row, column) {
        return root.editingRow === row && root.editingColumn === column
    }

    function startEdit(row, column) {
        if (!root.editable) {
            return
        }
        root.selectCell(row, column)
        root.editingRow = row
        root.editingColumn = column
    }

    function cancelEdit() {
        root.editingRow = -1
        root.editingColumn = -1
    }

    function commitEdit(row, column, value) {
        if (!root.isEditing(row, column)) {
            return
        }

        var index = root.model.index(row, column)
        var ok = root.model.setData(index, "display", value)
        if (ok) {
            root.cellEdited(row, column, root.columnRole(column), value)
        }
        root.cancelEdit()
    }

    function activateHeader(column) {
        var definition = root.columnDefinition(column)
        if (!definition || definition.sortable === false) {
            root.headerClicked(column)
            return
        }

        if (root.sortColumn === column) {
            root.sortOrder = root.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder
        } else {
            root.sortColumn = column
            root.sortOrder = Qt.AscendingOrder
        }

        root.headerClicked(column)
        root.sortRequested(column, root.columnRole(column), root.sortOrder)
    }

    Component {
        id: defaultDelegate

        TableViewDelegate {
            implicitWidth: root.columnWidthProvider(column)
            implicitHeight: root.rowHeight
            selected: root.selectable && root.selectedRow === row
            currentCell: root.selectable && root.selectedRow === row && root.selectedColumn === column
            rowHovered: root.hoveredRow === row
            rowPressed: root.pressedRow === row
            alternate: root.alternatingRowColors && row % 2 === 1
            showGridLines: root.showGridLines
            showRowSeparator: root.showRowSeparators || root.showGridLines
            showSelectionIndicator: column === 0
            firstColumn: column === 0
            lastColumn: root.isLastColumn(column)

            middleArea: [
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: root.columnAlignment(column)
                    typography: Typography.Body
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    visible: !root.isEditing(row, column)
                    text: root.cellText(model, column)
                },
                TextField {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    height: root.rowHeight - 8
                    frameless: false
                    clearEnabled: true
                    visible: root.isEditing(row, column)
                    text: root.cellText(model, column)

                    function submit() {
                        root.commitEdit(row, column, text)
                    }

                    onVisibleChanged: {
                        if (visible) {
                            text = root.cellText(model, column)
                            forceActiveFocus()
                            selectAll()
                        }
                    }
                    onAccepted: submit()
                    onActiveFocusChanged: {
                        if (!activeFocus && visible) {
                            submit()
                        }
                    }
                    Keys.onEscapePressed: root.cancelEdit()
                }
            ]

            TapHandler {
                acceptedButtons: Qt.LeftButton
                onDoubleTapped: root.startEdit(row, column)
            }

            onClicked: {
                root.selectCell(row, column)
                root.cellClicked(row, column)
            }

            onPressedChanged: {
                root.pressedRow = pressed ? row : -1
            }

            onHoveredChanged: {
                if (hovered) {
                    hoverClearTimer.stop()
                    root.pendingHoverClearRow = -1
                    root.hoveredRow = row
                } else if (root.hoveredRow === row) {
                    root.pendingHoverClearRow = row
                    hoverClearTimer.restart()
                }
            }
        }
    }
}
