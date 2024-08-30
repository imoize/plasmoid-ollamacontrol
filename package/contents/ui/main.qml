import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.notification
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import "Utils.js" as Utils

PlasmoidItem {
    id: main

    property bool ollamaRunning: false
    property var cfg: plasmoid.configuration
    property var delayCallback: function() {}
    signal pop()

    switchWidth: Kirigami.Units.gridUnit * 5
    switchHeight: Kirigami.Units.gridUnit * 5
    toolTipMainText: i18n("Ollama Control")

    Component.onCompleted: () => {
        Utils.checkStat();
    }

    ListModel {
        id: models
    }

    ListModel {
        id: runningModels
    }

    Timer {
        id: delayTimer
        interval: 1500
        repeat: false
        onTriggered: {
            if (delayCallback) {
                delayCallback();
            }
            delayTimer.interval = 1500;
        }
    }

    function delayTimerCallback(callback, interval) {
        if (interval === undefined) {
            interval = delayTimer.interval;
        }
        delayTimer.interval = interval;
        delayCallback = callback;
        delayTimer.start();
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            id: actionButton
            property string command: "startOllama"
            text: i18n("Start Ollama")
            icon.name: Qt.resolvedUrl("icons/start.svg")
            enabled: cfg.ollamaUrl.startsWith("http://localhost") || cfg.ollamaUrl.startsWith("http://127.0.0.1")
            onTriggered: {
                if (command === "startOllama") {
                    Utils.commands["startOllama"].run();
                } else if (command === "stopOllama") {
                    Utils.commands["stopOllama"].run();
                }
            }
        }
    ]

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var cmd = sourceName
            var out = data["stdout"].replace(/\u001b\[[0-9;]*[m|K]/g, '')
            var err = data["stderr"]
            var code = data["exit code"]
            var listener = listeners[cmd]

            if (listener) listener(cmd, out, err, code)

            exited(cmd, out, err, code)
            disconnectSource(sourceName)
        }

        signal exited(string cmd, string out, string err, int code)

        property var listeners: ({})

        function exec(cmd, callback) {
            listeners[cmd] = execCallback.bind(executable, callback)
            console.log("Running command:", cmd)
            connectSource(cmd)
        }

        function endAll(){
            for( var proc in listeners ){
                delete listeners[proc]
                disconnectSource(proc)
            }
        }

        function execCallback(callback, cmd, out, err, code) {
            delete listeners[cmd]
            if (callback) callback(cmd, out, err, code)
        }
    }

    compactRepresentation: MouseArea {
        id: compact
        property bool wasExpanded: false
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: true
        onPressed: (mouse) => {
            wasExpanded = main.expanded
        }
        onClicked: (mouse) => {
            main.expanded = !wasExpanded;
            main.pop();
        }
        
        Kirigami.Icon {
        id: compactIcon
        anchors.fill: parent
        active: compact.containsMouse
        activeFocusOnTab: true
        source: Qt.resolvedUrl("icons/ollama-symbolic.svg")
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        id: dialogItem
        Layout.minimumWidth: Kirigami.Units.gridUnit * 24
        Layout.minimumHeight: Kirigami.Units.gridUnit * 24
        Layout.maximumWidth: Kirigami.Units.gridUnit * 80
        Layout.maximumHeight: Kirigami.Units.gridUnit * 40
        collapseMarginsHint: true

        header: stack.currentItem.header
        footer: stack.currentItem.footer

        QQC2.StackView {
            id: stack
            anchors.fill: parent
            initialItem: ListPage {
                id: listPage
            }

            Connections {
                target: main
                function onPop() {
                    stack.pop();
                }
            }
        }
    }
}