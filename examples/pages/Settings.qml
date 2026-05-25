import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML

FluentPage {
    title: qsTr("Settings")

    Column {
        Layout.fillWidth: true
        spacing: 3
        Text {
            typography: Typography.BodyStrong
            text: qsTr("Appearance")
        }

        SettingCard {
            width: parent.width
            title: qsTr("App Theme")
            description: qsTr("Select which app theme to display")
            icon.name: "ic_fluent_paint_brush_20_regular"

            ComboBox {
                property var data: [Theme.mode.Light, Theme.mode.Dark, Theme.mode.Auto]
                model: ListModel {
                    ListElement { text: qsTr("Light") }
                    ListElement { text: qsTr("Dark") }
                    ListElement { text: qsTr("Use system setting") }
                }
                currentIndex: data.indexOf(Theme.getTheme())
                onCurrentIndexChanged: {
                    Theme.setTheme(data[currentIndex])
                }
            }
        }

        SettingCard {
            width: parent.width
            title: qsTr("Window Backdrop Effect")
            description: backdropEffectBox.isMacOS
                ? qsTr("Adjust the macOS window material")
                : qsTr("Adjust the appearance of the window background (Only available on Windows platform, some styles may only support on Windows 11)")
            icon.name: "ic_fluent_square_hint_sparkles_20_regular"

            ComboBox {
                id: backdropEffectBox
                property bool isMacOS: Qt.platform.os === "osx" || Qt.platform.os === "macos" || Qt.platform.os === "darwin"
                property bool initialized: false
                property var data: isMacOS ? ["system", "hud", "none"] : ["mica", "acrylic", "tabbed", "none"]
                property var labels: isMacOS
                    ? [qsTr("System Material"), qsTr("HUD Material"), qsTr("None")]
                    : [qsTr("Mica"), qsTr("Acrylic"), qsTr("Tabbed"), qsTr("None")]
                model: labels

                Component.onCompleted: {
                    currentIndex = Math.max(0, data.indexOf(Theme.getBackdropEffect()))
                    initialized = true
                }

                onCurrentIndexChanged: {
                    if (initialized && currentIndex >= 0 && currentIndex < data.length) {
                        Theme.setBackdropEffect(data[currentIndex])
                    }
                }
            }
        }

        SettingCard {
            width: parent.width
            title: qsTr("Accent Color")
            description: qsTr("Pick the color which app highlighted color")
            icon.name: "ic_fluent_paint_brush_20_regular"

            DropDownColorPicker {
                position: Position.Left

                color: Theme.getThemeColor()
                onColorChanged: {
                    Theme.setThemeColor(color)
                }
            }
        }
    }

    Column {
        Layout.fillWidth: true
        spacing: 3
        Text {
            typography: Typography.BodyStrong
            text: qsTr("Language")
        }

        SettingCard {
            width: parent.width
            title: qsTr("Display Language")
            description: qsTr("Set your preferred language for the gallery")
            icon.name: "ic_fluent_translate_20_regular"

            ComboBox {
                property var data: [Backend.getSystemLanguage(), "en_US", "zh_CN"]
                property bool initialized: false
                model: ListModel {
                    ListElement { text: qsTr("Use System Language") }
                    ListElement { text: "English (US)" }
                    ListElement { text: "简体中文" }
                }
                Component.onCompleted: {
                    currentIndex = data.indexOf(Backend.getLanguage())
                    initialized = true
                }

                onCurrentIndexChanged: {
                    if (initialized) {
                        Backend.setLanguage(data[currentIndex])
                    }
                }
            }
        }
    }


    Column {
        Layout.fillWidth: true
        spacing: 3
        Text {
            typography: Typography.BodyStrong
            text: qsTr("About")
        }

        SettingExpander {
            width: parent.width
            title: qsTr("FluentQML Gallery")
            description: qsTr("© 2026 Cheukfung. All rights reserved.")
            icon.source: Qt.resolvedUrl("../assets/gallery.png")
            icon.size: 28

            content: Text {
                color: Theme.currentTheme.colors.textSecondaryColor
                text: Backend.getVersion()
            }

            SettingItem {
                id: repo
                title: qsTr("To clone this repository")

                TextInput {
                    id: repoUrl
                    readOnly: true
                    text: "git clone https://github.com/Cheukfung/Fluent-QML.git"
                    wrapMode: TextInput.Wrap
                }
                ToolButton {
                    flat: true
                    icon.name: "ic_fluent_copy_20_regular"
                    onClicked: {
                        Backend.copyToClipboard(repoUrl.text)
                    }
                }
            }
            SettingItem {
                title: qsTr("File a bug or request new sample")

                Hyperlink {
                    text: qsTr("Create an issue on GitHub")
                    openUrl: "https://github.com/Cheukfung/Fluent-QML/issues/new/choose"
                }
            }
            SettingItem {
                Column {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Dependencies & references")
                    }
                    Hyperlink {
                        text: qsTr("Qt & Qt Quick")
                        openUrl: "https://www.qt.io/"
                    }
                    Hyperlink {
                        text: qsTr("Fluent Design System")
                        openUrl: "https://fluent2.microsoft.design/"
                    }
                    Hyperlink {
                        text: qsTr("Fluent UI System Icons")
                        openUrl: "https://github.com/microsoft/fluentui-system-icons/"
                    }
                    Hyperlink {
                        text: qsTr("WinUI 3 Gallery")
                        openUrl: "https://github.com/microsoft/WinUI-Gallery"
                    }
                }
            }
            SettingItem {
                title: qsTr("License")
                description: qsTr("This project is licensed under the MIT license")

                Hyperlink {
                    text: qsTr("MIT License")
                    openUrl: "https://github.com/Cheukfung/Fluent-QML/blob/master/LICENSE"
                }
            }
        }
    }
}
