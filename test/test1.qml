import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import FluentQML


ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Demo Settings Panel"

    Component.onCompleted: {
        Utils.fontFamily = "Microsoft YaHei"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        InfoBar {
            title: qsTr("提示")
            text: qsTr("请先填写所有必填项")
        }

        Text {
            text: "应用设置"
            font.pixelSize: 28
            font.bold: true
        }

        // 第一组：基本控件
        GroupBox {
            title: "常规"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 12
                width: parent.width

                RowLayout {
                    spacing: 12
                    Text { text: "用户名：" }
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "请输入用户名"
                    }
                }

                RowLayout {
                    spacing: 12
                    Text { text: "启用功能：" }
                    Switch { checked: true }
                }

                RowLayout {
                    spacing: 12
                    Text { text: "音量：" }
                    Slider {
                        from: 0
                        to: 100
                        value: 70
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // 第二组：高级选项
        GroupBox {
            title: "高级设置"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 12
                width: parent.width

                RowLayout {
                    spacing: 12
                    Text { text: "颜色主题：" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["浅色", "深色", "系统默认"]
                    }
                }

                RowLayout {
                    spacing: 12
                    Text { text: "最大线程数：" }
                    SpinBox {
                        from: 1
                        to: 64
                        value: 8
                    }
                }

                CheckBox {
                    text: "启用实验性特性"
                    checked: false
                }
            }
        }

        // 第三组：操作按钮
        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignRight
            Button {
                text: "取消"
            }
            Button {
                text: "保存"
                highlighted: true

                onClicked: {
                    onAccepted: {
                    floatLayer.createInfoBar({
                        severity: Severity.Success,
                        title: qsTr("成功"),
                        text: qsTr("您现在应该可以使用功能了，如果还不能使用，请切换一下界面")
                    })}
                }
            }
        }
    }
}
