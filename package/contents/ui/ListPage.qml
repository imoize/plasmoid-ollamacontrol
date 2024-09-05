import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import "Utils.js" as Utils

ColumnLayout {
    id: listPage
    property alias view: modelListView
    property alias model: modelListView.model
    property alias modelsCombobox: modelsCombobox
    property string modelName: ""

    property var header: PlasmaExtras.PlasmoidHeading {
        contentItem: RowLayout {
            spacing: 0
            enabled: models.count > 0

            PlasmaExtras.SearchField {
                id: filter
                Layout.fillWidth: true
            }

            PlasmaComponents.ToolButton {
                text: i18n("Refresh")
                icon.name: Qt.resolvedUrl("icons/refresh.svg")
                onClicked: {
                    Utils.getModels();
                }
                display: QQC2.AbstractButton.IconOnly
                PlasmaComponents.ToolTip{ text: parent.text }
            }
        }
    }

    property var footer: PlasmaExtras.PlasmoidHeading {
        contentItem: RowLayout {
            enabled: runningModels.count > 0

            PlasmaComponents.ComboBox {
                id: modelsCombobox

                Layout.fillWidth: true
                model: runningModels
                textRole: "text"
                currentIndex: 0
                displayText: currentIndex === -1 ? "List Running Models" : currentText
            }

            PlasmaComponents.Button {
                id: ejectButton
                enabled: modelsCombobox.currentIndex !== -1
                text: i18n("Eject")
                icon.name: Qt.resolvedUrl("icons/eject.svg")
                onClicked: {
                    var model = modelsCombobox.currentText
                    Utils.unloadModel(model);
                }
                PlasmaComponents.ToolTip{ text: i18n("Eject Model") }
            }
        }
    }

    Connections {
        target: main
        function onExpandedChanged() {
            if (main.expanded) {
                Utils.checkStat();
                if (ollamaRunning) {
                    Utils.getModels();
                }
            } else {
                deleteDialog.close();
            }
        }
    }

    PlasmaComponents.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        background: null

        contentItem: ListView {
            id: modelListView
            model: models
            highlight: PlasmaExtras.Highlight { }
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
            currentIndex: -1

            delegate: ModelsDelegate {
                showSeparator: index !== 0
                width: modelListView.width
            }

            function openDialog(modelName) {
                deleteDialog.open();
                listPage.modelName = modelName;
            }

            QQC2.Dialog {
                id: deleteDialog
                anchors.centerIn: parent
                contentWidth: Kirigami.Units.gridUnit * 13
                modal: true
                standardButtons: QQC2.Dialog.Yes | QQC2.Dialog.Cancel
                closePolicy: QQC2.Popup.NoAutoClose | QQC2.Popup.CloseOnPressOutside

                PlasmaComponents.Label {
                    id: dialogMessage
                    anchors.centerIn: parent
                    width: deleteDialog.contentWidth
                    // width: Kirigami.Units.gridUnit * 13
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    wrapMode: Text.WordWrap
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                    text: i18n("Delete '" + modelName + "' model ?")
                }

                footer: QQC2.DialogButtonBox {
                    alignment: Qt.AlignHCenter
                }

                onAccepted: Utils.deleteModel(modelName);
                onRejected: {
                    deleteDialog.close();
                }
            }
        }
    }

    model: KItemModels.KSortFilterProxyModel {
        id: filterModel
        sourceModel: models
        filterRoleName: "modelName"
        filterRegularExpression: RegExp(filter.text, "i")
        filterCaseSensitivity: Qt.CaseInsensitive
        sortCaseSensitivity: Qt.CaseInsensitive
        // sortRoleName: "ModelName"
        recursiveFilteringEnabled: true
        sortOrder: Qt.AscendingOrder
    }
}