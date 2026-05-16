import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("TextArea")

    // intro
    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Use a TextField to let a user enter multiple lines of text input in your app. You can add a placeholder text " +
            "to let the user know what the TextArea is for, and you can customize it in other ways."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple TextArea.")
        }
        Frame {
            width: parent.width
            TextArea {
                width: 200
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("A simple TextArea.")
        }
        Frame {
            width: parent.width
            TextArea {
                placeholderText: qsTr("Enter your profile...")
                width: 200
            }
        }
    }
    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("ScrollableTextArea rich text demo")
        }
        Frame {
            width: parent.width
            ColumnLayout {
                width: parent.width
                ScrollableTextArea {
                    id: demoScrollableRich
                    Layout.fillWidth: true
                    // maxHeight: 200
                    // richText: true
                    height: 150
                    placeholderText: qsTr("Paste rich text (HTML) here...")
                    textFormat: TextArea.RichText
                    text: "<h1>Heading 1</h1>" +
                        "<a href='https://example.com'>Link</a>" +
                        "<h2>Heading 2</h2>" +
                        "<h3>Heading 3</h3>" +
                        "<p style='font-family: Times New Roman; color: darkgray;'>" +
                        "Text in a TextBlock doesn't have to be a simple string.</p>" +
                        "<p>Text can be <b>bold</b>,\n" +
                        "<i>italic</i>, or <u>underlined</u>. </p>\n" +
                        "\n\n"

                    // text: "<h3>Rich Text Demo</h3>"
                    //     + "<p><b>Bold</b>, <i>Italic</i>, <span style='color:#0078d4'>Primary color span</span>, and a <a href='https://example.com'>link</a>.</p>"
                    //     + "<ul><li>Item A</li><li>Item B</li><li>Item C</li></ul>"
                    //     + "<p style='font-size:18pt;color:#0078d4'>落霞与孤鹜齐飞，秋水共长天一色。</p>"
                    //     + "<p style='color:#1abc9c'>渔舟唱晚，响穷彭蠡之滨，雁阵惊寒，声断衡阳之浦。</p>"
                    //     + "<p>换行测试。</p>"
                    //     + "<p>换行测试。</p>"
                    //     + "<p>换行测试。</p>"
                }
            }
        }
    }
}
