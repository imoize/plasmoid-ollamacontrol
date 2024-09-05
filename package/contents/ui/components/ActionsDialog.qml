import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Dialog {
    id: actionsDialog

    property string modelName: ""
    property string action: ""
    signal doActions(string modelName, string destination, string action)
    signal closeActionsDialog

    anchors.centerIn: parent
    contentWidth: Kirigami.Units.gridUnit * 18
    height: actionsDialogItem.height + footer.height + Kirigami.Units.gridUnit
    bottomInset: -10

    dim: true
    modal: true
    visible: true
    closePolicy: QQC2.Popup.CloseOnPressOutside

    ColumnLayout {
        id: actionsDialogItem
        anchors.centerIn: parent
        Layout.preferredWidth: actionsDialog.width
        Layout.fillWidth: true
        Layout.fillHeight: true

        PlasmaComponents.Label {
            id: copyMessage
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.smallSpacing * 2
            Layout.bottomMargin: Kirigami.Units.smallSpacing * 2
            Layout.preferredWidth: actionsDialog.contentWidth
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            wrapMode: Text.WordWrap
            text: {
                if (actionsDialog.action === "copy") {
                    return i18n("Copy \"%1\" to:", actionsDialog.modelName);
                } else if (actionsDialog.action === "delete") {
                    return i18n("Delete \"%1\" model ?", actionsDialog.modelName);
                } else {
                    return "";
                }
            }
        }

        PlasmaComponents.TextField {
            id: copyDestination
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width
            Layout.fillWidth: true
            visible: actionsDialog.action === "copy" ? true : false
            focus: true
            placeholderText: i18n("e.g. llama3.1-instruct, llama3.1:instruct")
            onTextChanged: {
                if (copyDestination.text !== "") {
                    actionsDialog.standardButton(QQC2.Dialog.Ok).enabled = true;
                } else {
                    actionsDialog.standardButton(QQC2.Dialog.Ok).enabled = false;
                }
            }
        }
    }

    footer: QQC2.DialogButtonBox {
        id: dialogButtonBox
        alignment: Qt.AlignHCenter
    }

    QQC2.Overlay.modal: Rectangle {
        color: "#50000000"
        bottomLeftRadius: 5
        bottomRightRadius: 5
    }

    onAccepted: {
        if (actionsDialog.action === "copy") {
            const destination = copyDestination.text;
            if (copyDestination.text !== "") {

            }
            actionsDialog.closeActionsDialog();
        } else if (actionsDialog.action === "delete") {
            actionsDialog.doActions(modelName, undefined, "delete");
        }
        actionsDialog.closeActionsDialog();
    }
    onRejected: {
        actionsDialog.closeActionsDialog();
    }
}
