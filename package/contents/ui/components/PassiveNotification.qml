import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Popup {
    id: passiveNotification

    signal closePassiveNotification

    width: Kirigami.Units.gridUnit * 6
    height: Kirigami.Units.gridUnit * 2 - 4

    // Position the Popup at the bottom of its parent
    x: parent.width / 2 - width / 2  // Center horizontally
    y: parent.height - height - 2 // Position at the bottom

    modal: false
    visible: true
    closePolicy: PlasmaComponents.Popup.CloseOnPressOutside

    PlasmaComponents.Label {
        anchors.centerIn: parent
        Layout.alignment: Qt.AlignHCenter
        horizontalAlignment: Text.AlignHCenter
        text: "Text copied !"
    }

    background: Rectangle {
        anchors.fill: parent
        radius: 50
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
    }

    // Timer to auto-close the Popup after a certain duration
    Timer {
        id: autoCloseTimer
        interval: 1500
        running: passiveNotification.visible
        onTriggered: {
            passiveNotification.close();
        }
    }

    onClosed: {
        passiveNotification.closePassiveNotification();
    }
}