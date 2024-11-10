import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import "Utils.js" as Utils

ColumnLayout {
    id: infoPage
    spacing: 0
    Layout.topMargin: 0
    Layout.bottomMargin: 0

    property string modelName: ""
    property alias modelInfoText: modelInfoText

    property PlasmaExtras.PlasmoidHeading header: PlasmaExtras.PlasmoidHeading {
        background.visible: false

        RowLayout {
            id: infoToolbar
            spacing: 0
            anchors.fill: parent

            PlasmaComponents.Label {
                id: modelNameLabel
                leftPadding: Kirigami.Units.smallSpacing
                text: "Model Name: " + modelName
                Layout.fillWidth: true
                font.bold: true
            }

            PlasmaComponents.Button {
                id: backButton
                icon.name: "go-previous-view"
                icon.width: 16
                icon.height: 16
                rightPadding: Kirigami.Units.smallSpacing * 3
                text: i18n("Back")
                onClicked: {
                    if (modelInfoText.text !== "") {
                        modelInfoText.text = "";
                    }
                    stack.pop();
                }
            }
        }
    }

    PlasmaComponents.ScrollView {
        id: infoScrollView

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: PlasmaComponents.ScrollBar.vertical.visible ? 0 : Kirigami.Units.smallSpacing
        contentWidth: PlasmaComponents.ScrollBar.vertical.visible ? infoScrollView.width - Kirigami.Units.smallSpacing * 6 : infoScrollView.width

        PlasmaComponents.TextArea {
            id: modelInfoText
            background: null
            width: infoScrollView.contentWidth
            readOnly: true
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
            text: ""
        }
    }

    Component.onCompleted: {
        Utils.showModelInfo(modelName);
    }
}