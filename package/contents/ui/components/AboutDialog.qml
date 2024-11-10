import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Kirigami.Dialog {
    id: aboutDialog
    title: i18n("About")
    signal closeAboutDialog

    closePolicy: QQC2.Popup.NoAutoClose
    standardButtons: QQC2.Dialog.NoButton
    preferredWidth: Kirigami.Units.gridUnit * 15
    leftPadding: 7
    rightPadding: 7
    bottomPadding: 5
    

        ColumnLayout {
            Layout.topMargin: 0
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            text: "Applet Version : " + plasmoid.metaData.version
            }

            PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            text: "Ollama Version : " + main.ollamaVersion
            }

            // PlasmaComponents.Label {
            //     Layout.alignment: Qt.AlignHCenter
            //     horizontalAlignment: Text.AlignHCenter
            //     text: "Update Available ! "
            // }

            RowLayout {
                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: 5

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "<a href='https://github.com/imoize/plasmoid-ollamacontrol'>GitHub</a>"
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                
                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "<a href='https://github.com/ollama/ollama'>Ollama GitHub</a>"

                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "<a href='https://github.com/ollama/ollama/tree/main/docs'>Help</a>"

                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                text: "This program comes with absolutely no warranty.<br>See the <a href='https://www.gnu.org/licenses/gpl-3.0.en.html'>GNU General Public License, version 3 or later</a> for details."
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
            }
        }

    QQC2.Overlay.modal: Rectangle {
        color: "#50000000"
        bottomLeftRadius: 5
        bottomRightRadius: 5
    }

    onClosed: {
        aboutDialog.closeAboutDialog();
    }

    Component.onCompleted: {
        aboutDialog.open();
    }
}