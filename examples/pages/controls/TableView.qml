import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import Qt.labs.qmlmodels  // model
import FluentQML as Fluent
import FluentQML
import "../../components"


ControlPage {
    id: page
    title: "TableView"

    Text {
        Layout.fillWidth: true
        typography: Typography.Body
        text: qsTr(
            "TableView is a component that allows you to display a collection of data in a tabular format. "
        )
    }

    // 示例
    TableModel {
        id: songInfos
        TableModelColumn { display: "title" }
        TableModelColumn { display: "artist" }
        TableModelColumn { display: "album" }
        TableModelColumn { display: "year" }
        TableModelColumn { display: "duration" }

        rows: [
            { title: "稻香", artist: "周杰伦", album: "魔杰座", year: "2008", duration: "3:43" },
            { title: "晴天", artist: "周杰伦", album: "叶惠美", year: "2003", duration: "4:29" },
            { title: "红豆", artist: "王菲", album: "唱游", year: "1998", duration: "4:18" },
            { title: "匆匆那年", artist: "王菲", album: "匆匆那年", year: "2014", duration: "4:03" },
            { title: "后来", artist: "刘若英", album: "我等你", year: "2000", duration: "5:41" },
            { title: "成全", artist: "刘若英", album: "年华", year: "2001", duration: "4:33" },
            { title: "十年", artist: "陈奕迅", album: "黑白灰", year: "2003", duration: "3:25" },
            { title: "富士山下", artist: "陈奕迅", album: "What's Going On...?", year: "2006", duration: "4:19" },
            { title: "突然好想你", artist: "五月天", album: "后青春期的诗", year: "2008", duration: "4:26" },
            { title: "知足", artist: "五月天", album: "知足 Just My Pride 最真杰作选", year: "2005", duration: "4:17" },
            { title: "小幸运", artist: "田馥甄", album: "我的少女时代", year: "2015", duration: "4:25" },
            { title: "你就不要想起我", artist: "田馥甄", album: "渺小", year: "2013", duration: "4:40" },
            { title: "泡沫", artist: "邓紫棋", album: "Xposed", year: "2012", duration: "4:18" },
            { title: "光年之外", artist: "邓紫棋", album: "光年之外", year: "2016", duration: "3:55" },
            { title: "平凡之路", artist: "朴树", album: "猎户星座", year: "2014", duration: "5:02" },
            { title: "生如夏花", artist: "朴树", album: "生如夏花", year: "2003", duration: "4:49" },
            { title: "起风了", artist: "买辣椒也用券", album: "起风了", year: "2017", duration: "5:25" },
            { title: "岁月神偷", artist: "金玟岐", album: "完美世界", year: "2014", duration: "4:15" }
        ]
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: "TableView with Fluent Item Delegate"
        }
        Frame {
            width: parent.width
            height: tableView.height + topPadding + bottomPadding
            Column {
                width: parent.width
                spacing: 4
                Fluent.TableView {
                    id: tableView
                    width: parent.width
                    height: 400

                    model: songInfos
                    selectedRow: 0
                    selectedColumn: 0
                    borderVisible: true
                    borderRadius: 8
                    columnDefinitions: [
                        {
                            title: "Title",
                            role: "title",
                            width: 190,
                            minimumWidth: 150
                        },
                        {
                            title: "Artist",
                            role: "artist",
                            width: 140,
                            minimumWidth: 120
                        },
                        {
                            title: "Album",
                            role: "album",
                            width: 220,
                            minimumWidth: 160
                        },
                        {
                            title: "Year",
                            role: "year",
                            width: 100,
                            minimumWidth: 80
                        },
                        {
                            title: "Duration",
                            role: "duration",
                            width: 110,
                            minimumWidth: 90
                        }
                    ]

                    onSortRequested: function(column, role, order) {
                        console.log("Table sort requested:", column, role, order)
                    }
                }
            }
        }
    }
}
