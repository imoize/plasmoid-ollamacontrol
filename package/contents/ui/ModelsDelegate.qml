import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "Utils.js" as Utils

PlasmaComponents.ItemDelegate {
    id: modelItem
    height: Math.max(label.height, Math.round(Kirigami.Units.gridUnit * 1.6)) + 2 * Kirigami.Units.smallSpacing
    enabled: true

    property bool showSeparator

    signal toInfoPage(string modelName)

    onToInfoPage: (modelName) => {
        stack.push(Qt.resolvedUrl("InfoPage.qml"), {
            modelName: modelName
        });
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: isLoading ? false : true
        onEntered: {
            modelListView.currentIndex = index;
        }
        onExited: {
            if (modelListView.currentIndex === index)
                modelListView.currentIndex = -1;
        }
        onClicked: {
            modelItem.toInfoPage(modelName);
        }

        Item {
            id: label
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Kirigami.Units.gridUnit - 9.2
                // rightMargin: Kirigami.Units.gridUnit - 3.2
                verticalCenter: parent.verticalCenter
            }
            height: labelLayout.height

            RowLayout {
                id: labelLayout
                spacing: 0

                ColumnLayout {
                    spacing: 0

                    PlasmaComponents.Label {
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                        id: modelNameLabel
                        text: modelName
                        font.bold: true

                        PlasmaComponents.ToolTip {
                            id: modelNameTooltip
                            visible: false
                            text: i18n("Click to copy text")
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                modelNameTooltip.visible = true
                            }
                            onExited: {
                                modelNameTooltip.visible = false
                            }
                            onClicked: {
                                // Use TextEdit as a helper to copy the text to the clipboard
                                textEditHelper.text = modelNameLabel.text;
                                textEditHelper.selectAll();
                                textEditHelper.copy();
                                listPage.showPassiveNotification();
                            }
                        }
                    }

                    // Helper TextEdit element to facilitate copying text to the clipboard
                    TextEdit {
                        id: textEditHelper
                        visible: false
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
                    icon.name: Qt.resolvedUrl("icons/oc-up-square.svg")
                    onClicked: {
                        var model = modelName;
                        Utils.handleModel(modelName, "load");
                    }
                    display: QQC2.AbstractButton.IconOnly
                    PlasmaComponents.ToolTip {
                        text: parent.text
                    }
                }

                PlasmaComponents.ToolButton {
                    id: contextMenuButton
                    property var contextMenu: null
                    // anchors.centerIn: parent
                    checkable: true
                    text: i18n("More")
                    icon.name: Qt.resolvedUrl("icons/oc-options.svg")
                    onClicked: {
                        createContextMenu(modelName);
                    }
                    display: QQC2.AbstractButton.IconOnly
                    PlasmaComponents.ToolTip {
                        text: parent.text
                    }

                    function createContextMenu(modelName) {
                        if (contextMenu === null) {
                            var component = Qt.createComponent("./components/ContextMenu.qml");
                            contextMenu = component.createObject(contextMenuButton);
                            contextMenuButton.checked = true;
                            contextMenu.modelName = modelName;
                            contextMenu.open();
                            if (contextMenu !== null) {
                                contextMenu.closeContextMenu.connect(destroyContextMenu);
                            }
                        }
                    }

                    function destroyContextMenu() {
                        if (contextMenu !== null) {
                            contextMenu.destroy();
                            contextMenuButton.checked = false;
                            contextMenu = null;
                        }
                    }
                }
                
                Connections {
                    target: main
                    function onExpandedChanged() {
                        if (!main.expanded) {
                            contextMenuButton.destroyContextMenu();
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
            top: parent.bottom
        }
        imagePath: "widgets/line"
        elementId: "horizontal-line"
        width: parent.width - Kirigami.Units.gridUnit
        visible: showSeparator
    }
}
