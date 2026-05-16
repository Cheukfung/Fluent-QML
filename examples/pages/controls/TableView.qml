import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import Qt.labs.qmlmodels  // model
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
        id: studentsInfo
        TableModelColumn { display: "name" }
        TableModelColumn { display: "school" }
        TableModelColumn { display: "age" }

        rows: [
            { name: "Aikiyo Fuuka", school: "Gehenna",    age: 16 },  // 风香
            { name: "Hayase Yuuka", school: "Millennium", age: 16 },  // 邮箱
            { name: "Hanaoka Yuzu", school: "Millennium", age: 16 },  // 柚子
            { name: "Kuromi Serika", school: "Abydos",    age: 15 },  // 芹香
            { name: "Kurosaki Koyuki", school: "Millennium", age: 15 }, // 小雪
            { name: "Kuda Izuna", school: "Hyakkiyako",   age: 15 },  // 泉奈
            { name: "Okusora Ayane", school: "Trinity",   age: 15 },  // 绫音
            { name: "Saiba Midori", school: "Millennium", age: 15 },  // 绿
            { name: "Saiba Momoi", school: "Millennium",  age: 15 },  // 桃
            { name: "Shiromi Iori", school: "Gehenna",    age: 16 },  // 伊织
            { name: "Shishidou Nonomi", school: "Abydos", age: 16 },  // 野宫
            { name: "Sunaookami Shiroko", school: "Abydos", age: 16 }, // 白子 😋
            { name: "Tendou Aris", school: "Millennium",  age: "??" }, // Aris
            { name: "Ushio Noa", school: "Millennium",    age: 16 },  // 诺亚
            { name: "Yutori Natsu", school: "Trinity",    age: 15 }   // 夏
        ]
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
                text: "Basic ListView with Simple DataTemplate"
        }
        Frame {
            width: parent.width
            Column {
                spacing: 4
                Text {
                    width: parent.parent.width
                    text: "This is a basic ListView that has the full source code below (coming soon). \n" +
                        "Other samples on this page display only the additional markup needed customize " +
                        "the ListView like this one."
                }

                TableView {
                    id: tableView
                    width: parent.width
                    height: 400

                    model: studentsInfo
                    //
                    // delegate: Rectangle {
                    //     implicitWidth: 100
                    //     implicitHeight: 50
                    //     border.width: 1
                    //     color: "transparent"
                    //
                    //     Text {
                    //         text: display
                    //         anchors.centerIn: parent
                    //     }
                    // }
                }
            }
        }
    }
}
