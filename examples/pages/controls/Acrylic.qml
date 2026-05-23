import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import FluentQML
import "../../components"

ControlPage {
    title: qsTr("Acrylic")
    badgeText: qsTr("Material")
    badgeSeverity: Severity.Success

    Text {
        Layout.fillWidth: true
        text: qsTr(
            "Acrylic uses a captured snapshot of the content behind the control, applies blur, " +
            "and overlays theme tint, luminosity, noise, and border layers."
        )
    }

    Column {
        Layout.fillWidth: true
        spacing: 4

        Text {
            typography: Typography.BodyStrong
            text: qsTr("Acrylic panel over detailed content.")
        }

        ControlShowcase {
            width: parent.width
            height: 340
            showcaseWidth: 220

            Item {
                width: parent.width
                height: 300

                Image {
                    id: acrylicBackdrop
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../../assets/banner.png")
                    fillMode: Image.PreserveAspectCrop

                    onStatusChanged: {
                        if (status === Image.Ready) {
                            panelHost.requestInitialRefresh()
                        }
                    }
                }

                Grid {
                    anchors.fill: parent
                    anchors.margins: 20
                    columns: 6
                    rows: 3
                    spacing: 12

                    Repeater {
                        model: 18
                        Rectangle {
                            width: Math.max(42, (parent.width - parent.spacing * 5) / 6)
                            height: Math.max(46, (parent.height - parent.spacing * 2) / 3)
                            radius: Theme.currentTheme.appearance.buttonRadius
                            color: Qt.hsla((index * 0.075) % 1, 0.65, Theme.isDark() ? 0.38 : 0.58, 0.82)
                            border.color: Qt.alpha("#ffffff", 0.35)
                        }
                    }
                }

                Item {
                    id: panelHost
                    width: Math.min(360, parent.width - 56)
                    height: 196
                    anchors.centerIn: parent

                    property bool ready: false

                    function refreshAcrylic() {
                        if (!ready) {
                            return
                        }
                        acrylicPanel.opacity = 0
                        acrylicContent.opacity = 0
                        captureTimer.restart()
                    }

                    function requestInitialRefresh() {
                        if (!ready || acrylicBackdrop.status !== Image.Ready) {
                            return
                        }
                        initialRefreshTimer.restart()
                    }

                    Component.onCompleted: {
                        ready = true
                        requestInitialRefresh()
                    }

                    AcrylicPanel {
                        id: acrylicPanel
                        anchors.fill: parent
                        autoRefresh: false
                        radius: radiusSlider.value
                        blurRadius: blurSlider.value
                        maxBlurSize: maxSizeSlider.value
                        noiseOpacity: noiseSlider.value
                        lightTintColor: Qt.rgba(1, 1, 1, tintSlider.value)
                        darkTintColor: Qt.rgba(32 / 255, 32 / 255, 32 / 255, tintSlider.value)
                    }

                    ColumnLayout {
                        id: acrylicContent
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Icon {
                                name: "ic_fluent_weather_sunny_low_20_regular"
                                size: 26
                                color: Theme.currentTheme.colors.textColor
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    typography: Typography.BodyStrong
                                    text: qsTr("Snapshot acrylic")
                                }

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.currentTheme.colors.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    text: qsTr("The content stays crisp while the material underneath is blurred.")
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Button {
                                text: qsTr("Refresh")
                                icon.name: "ic_fluent_arrow_sync_20_regular"
                                onClicked: panelHost.refreshAcrylic()
                            }

                            Button {
                                text: qsTr("Toggle theme")
                                icon.name: "ic_fluent_dark_theme_20_regular"
                                onClicked: Theme.toggleMode()
                            }
                        }
                    }

                    Timer {
                        id: captureTimer
                        interval: 40
                        repeat: false
                        onTriggered: {
                            acrylicPanel.refresh()
                            restoreTimer.restart()
                        }
                    }

                    Timer {
                        id: initialRefreshTimer
                        interval: 160
                        repeat: false
                        onTriggered: panelHost.refreshAcrylic()
                    }

                    Timer {
                        id: restoreTimer
                        interval: 40
                        repeat: false
                        onTriggered: {
                            acrylicPanel.opacity = 1
                            acrylicContent.opacity = 1
                        }
                    }
                }
            }

            showcase: [
                Text {
                    text: qsTr("Blur radius")
                },
                Slider {
                    id: blurSlider
                    width: 160
                    from: 0
                    to: 45
                    stepSize: 1
                    value: 30
                    onValueChanged: panelHost.refreshAcrylic()
                },
                Text {
                    text: qsTr("Tint opacity")
                },
                Slider {
                    id: tintSlider
                    width: 160
                    from: 0.45
                    to: 0.88
                    stepSize: 0.01
                    value: Theme.isDark() ? 200 / 255 : 180 / 255
                },
                Text {
                    text: qsTr("Noise opacity")
                },
                Slider {
                    id: noiseSlider
                    width: 160
                    from: 0
                    to: 0.08
                    stepSize: 0.01
                    value: 0.03
                },
                Text {
                    text: qsTr("Radius")
                },
                Slider {
                    id: radiusSlider
                    width: 160
                    from: 0
                    to: 24
                    stepSize: 1
                    value: 8
                },
                Text {
                    text: qsTr("Max blur size")
                },
                Slider {
                    id: maxSizeSlider
                    width: 160
                    from: 180
                    to: 720
                    stepSize: 30
                    value: 450
                    onValueChanged: panelHost.refreshAcrylic()
                }
            ]
        }
    }
}
