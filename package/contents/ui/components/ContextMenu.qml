import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Menu {
    id: contextMenu

    property string modelName: ""
    signal closeContextMenu

    width: Kirigami.Units.gridUnit * 8
    margins: Kirigami.Units.smallSpacing * 3
    y: contextMenuButton.height
    modal: true
    closePolicy: QQC2.Popup.CloseOnPressOutside

    PlasmaComponents.MenuItem {
        id: copyMenuItem
        text: i18n("Copy")
        icon.name: Qt.resolvedUrl("../icons/copy.svg")
        onTriggered: {
            listPage.createActionsDialog(modelName, "copy");
        }
        onHoveredChanged: {
            if (!hovered) {
                highlighted = false;
            }
        }
        PlasmaComponents.ToolTip {
            text: i18n("Creates a model with another name from an existing model.")
        }
    }

    // PlasmaComponents.MenuSeparator {}

    // PlasmaComponents.MenuItem {
    //     id: pushMenuItem
    //     text: i18n("Push")
    //     icon.name: Qt.resolvedUrl("../icons/up-tray.svg")
    //     onTriggered: {}
    //     onHoveredChanged: {
    //         if (!hovered) {
    //             highlighted = false;
    //         }
    //     }
    // }

    // PlasmaComponents.MenuItem {
    //     id: updateMenuItem
    //     text: i18n("Update")
    //     icon.name: Qt.resolvedUrl("../icons/down-tray.svg")
    //     onTriggered: {}
    //     onHoveredChanged: {
    //         if (!hovered) {
    //             highlighted = false;
    //         }
    //     }
    // }

    PlasmaComponents.MenuSeparator {}

    PlasmaComponents.MenuItem {
        id: deleteMenuItem
        text: i18n("Delete")
        icon.name: Qt.resolvedUrl("../icons/delete.svg")
        onTriggered: {
            listPage.createActionsDialog(modelName, "delete");
        }
        onHoveredChanged: {
            if (!hovered) {
                highlighted = false;
            }
        }
    }

    onClosed: {
        closeContextMenu();
    }
}
