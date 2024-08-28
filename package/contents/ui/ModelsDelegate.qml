import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "Utils.js" as Utils

PlasmaComponents.ItemDelegate {
    id: modeltem
    height: Math.max(label.height, Math.round(Kirigami.Units.gridUnit * 1.6)) + 2 * Kirigami.Units.smallSpacing
    enabled: true

    property bool showSeparator

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            modelListView.currentIndex = index
        }
        onExited: {
            if (modelListView.currentIndex === index)
                modelListView.currentIndex = -1;
        }

        Item {
            id: label
            height: labelLayout.height
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Kirigami.Units.gridUnit - 9.2
                // rightMargin: Kirigami.Units.gridUnit - 3.2
                verticalCenter: parent.verticalCenter
            }

            RowLayout {
                id: labelLayout
                spacing: 0

                ColumnLayout {
                    spacing: 0

                    PlasmaComponents.Label {
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                        text: modelName
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 0

                        ColumnLayout {
                            spacing: 2
                            Layout.preferredWidth: label.width / 3 - Kirigami.Units.gridUnit * 2.5

                            PlasmaComponents.Label {
                                text: i18n("Arch: ") + modelArch
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }

                            PlasmaComponents.Label {
                                text: i18n("Format: ") + modelFormat
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.preferredWidth: label.width / 3 - Kirigami.Units.gridUnit * 2.5

                            PlasmaComponents.Label {
                                text: i18n("Param: ") + modelParam
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }

                            PlasmaComponents.Label {
                                text: i18n("Size: ") + modelSize
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.preferredWidth: label.width / 3 - Kirigami.Units.gridUnit * 2.5

                            PlasmaComponents.Label {
                                text: i18n("Quant: ") + modelQuant
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }

                            PlasmaComponents.Label {
                                text: i18n("Modified: ") + modifiedTime
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 0
                anchors {
                    right: label.right
                    rightMargin: Kirigami.Units.smallSpacing
                    verticalCenter: parent.verticalCenter
                }

                PlasmaComponents.ToolButton {
                    id: loadModelButton
                    // anchors.centerIn: parent
                    text: i18n("Load Model")
                    icon.name: Qt.resolvedUrl("icons/up-square.svg")
                    onClicked: {
                        var model = modelName
                        Utils.loadModel(model);
                    }
                    display:QQC2.AbstractButton.IconOnly
                    PlasmaComponents.ToolTip { text: parent.text }
                }

                PlasmaComponents.ToolButton {
                    id: contextMenuButton
                    // anchors.centerIn: parent
                    checkable: true
                    checked: contextMenu.opened
                    text: i18n("More")
                    icon.name: Qt.resolvedUrl("icons/options.svg")
                    onClicked: { 
                        contextMenu.open();
                    }
                    display:QQC2.AbstractButton.IconOnly
                    PlasmaComponents.ToolTip { text: parent.text }
                    
                    QQC2.Menu {
                        id: contextMenu
                        modal: true
                        y: contextMenuButton.height + Kirigami.Units.smallSpacing
                        margins: Kirigami.Units.smallSpacing * 5
                        // width: Kirigami.Units.gridUnit * 7
                        closePolicy: QQC2.Popup.CloseOnPressOutside | QQC2.Popup.CloseOnReleaseOutside

                        QQC2.MenuItem {
                            text: i18n("Delete (WIP)")
                            icon.name: Qt.resolvedUrl("icons/delete.svg")
                            // onTriggered: {
                            //     listPage.view.openDialog(modelName);
                            // }
                        }
                    }
                }
            }
        }
    }

    KSvg.SvgItem {
        id: separatorLine
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
        imagePath: "widgets/line"
        elementId: "horizontal-line"
        width: parent.width - Kirigami.Units.gridUnit
        visible: showSeparator
    }
}