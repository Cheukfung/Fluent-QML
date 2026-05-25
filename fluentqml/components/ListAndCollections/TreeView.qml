import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 2.15
import "../../themes"
import "../../components"

Item {
    id: root
    clip: true

    property var model: []
    property string textRole: "text"
    property string childrenRole: "children"
    property string iconRole: "icon"
    property string expandedRole: "expanded"
    property string checkedRole: "checked"
    property bool checkable: false
    property bool showIcons: false
    property bool expandAllByDefault: false
    property int currentIndex: -1
    property string currentPath: ""
    property var currentItem: null
    property int rowHeight: 36
    property int indent: 20
    property int itemSpacing: 2
    property int leftPadding: 4
    property int rightPadding: 4
    property Component delegate: defaultDelegate
    property alias contentY: listView.contentY
    readonly property int count: visibleRowCount()
    readonly property alias totalCount: listView.count

    property var _flatModel: []
    property var _expandedPaths: ({})
    property int _revision: 0

    signal itemClicked(var item, int depth)
    signal itemExpanded(var item, bool expanded)
    signal itemChecked(var item, bool checked)

    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        spacing: root.itemSpacing
        model: root._flatModel
        delegate: root.delegate

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    Component {
        id: defaultDelegate
        TreeViewDelegate { }
    }

    Component.onCompleted: root.rebuild()
    onModelChanged: root.rebuild()
    onExpandAllByDefaultChanged: root.rebuild()
    onCurrentIndexChanged: root.syncCurrentPath()

    function rebuild() {
        root._flatModel = flatten(root.model)
        syncCurrentIndex()
    }

    function flatten(nodes) {
        var rows = []
        appendRows(rows, nodes, 0, "")
        return rows
    }

    function appendRows(rows, nodes, depth, parentPath) {
        if (!nodes) {
            return
        }

        for (var i = 0; i < nodes.length; ++i) {
            var item = nodes[i]
            var path = parentPath.length > 0 ? parentPath + "." + i : String(i)
            var children = childItems(item)
            rows.push({
                item: item,
                depth: depth,
                path: path,
                hasChildren: children.length > 0,
                parentPath: parentPath
            })

            if (children.length > 0) {
                appendRows(rows, children, depth + 1, path)
            }
        }
    }

    function childItems(item) {
        var children = item[root.childrenRole]
        if (!children) {
            return []
        }
        return children
    }

    function itemText(item) {
        return item[root.textRole]
    }

    function itemIcon(item, hasChildren) {
        if (item[root.iconRole]) {
            return item[root.iconRole]
        }
        if (!root.showIcons) {
            return ""
        }
        return hasChildren ? "ic_fluent_folder_20_regular" : "ic_fluent_document_20_regular"
    }

    function isExpanded(item, path) {
        if (root._expandedPaths[path] !== undefined) {
            return root._expandedPaths[path]
        }
        if (item[root.expandedRole] !== undefined) {
            return item[root.expandedRole]
        }
        return root.expandAllByDefault
    }

    function toggleExpanded(path) {
        var rowIndex = rowIndexFromPath(path)
        var row = root._flatModel[rowIndex]
        if (!row || !row.hasChildren) {
            return
        }

        var expandedPaths = root._expandedPaths
        expandedPaths[path] = !isExpanded(row.item, path)
        root._expandedPaths = expandedPaths
        root._revision += 1
        if (!expandedPaths[path] && isDescendantPath(root.currentPath, path)) {
            selectRow(rowIndex)
        }
        root.itemExpanded(row.item, expandedPaths[path])
        syncCurrentIndex()
    }

    function activateRow(index) {
        selectRow(index)
        var row = root._flatModel[index]
        if (row && row.hasChildren) {
            toggleExpanded(row.path)
        }
    }

    function rowIndexFromPath(path) {
        for (var i = 0; i < root._flatModel.length; ++i) {
            if (root._flatModel[i].path === path) {
                return i
            }
        }
        return -1
    }

    function selectRow(index) {
        var row = root._flatModel[index]
        if (!row) {
            return
        }
        root.currentIndex = index
        root.currentPath = row.path
        root.currentItem = row.item
        root.itemClicked(row.item, row.depth)
    }

    function setItemChecked(item, checked) {
        item[root.checkedRole] = checked
        root.itemChecked(item, checked)
        root._revision += 1
    }

    function setRowChecked(index, checked) {
        selectRow(index)
        var row = root._flatModel[index]
        if (row) {
            setItemChecked(row.item, checked)
        }
    }

    function syncCurrentPath() {
        var row = root._flatModel[root.currentIndex]
        if (!row) {
            return
        }
        root.currentPath = row.path
        root.currentItem = row.item
    }

    function syncCurrentIndex() {
        if (root.currentPath.length === 0 && root.currentIndex >= 0) {
            syncCurrentPath()
            return
        }

        var nextIndex = rowIndexFromPath(root.currentPath)
        if (nextIndex >= 0) {
            root.currentIndex = nextIndex
            root.currentItem = root._flatModel[nextIndex].item
            return
        }

        root.currentIndex = -1
        root.currentItem = null
    }

    function isRowVisible(path) {
        root._revision

        if (path.length === 0) {
            return true
        }

        var parts = path.split(".")
        var parentPath = ""
        for (var i = 0; i < parts.length - 1; ++i) {
            parentPath = parentPath.length > 0 ? parentPath + "." + parts[i] : parts[i]
            var parentIndex = rowIndexFromPath(parentPath)
            if (parentIndex < 0) {
                return false
            }

            var parentRow = root._flatModel[parentIndex]
            if (!isExpanded(parentRow.item, parentPath)) {
                return false
            }
        }

        return true
    }

    function visibleRowCount() {
        root._revision

        var total = 0
        for (var i = 0; i < root._flatModel.length; ++i) {
            if (isRowVisible(root._flatModel[i].path)) {
                total += 1
            }
        }
        return total
    }

    function isDescendantPath(path, parentPath) {
        return path.length > parentPath.length && path.indexOf(parentPath + ".") === 0
    }
}
