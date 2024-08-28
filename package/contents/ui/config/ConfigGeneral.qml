import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: generalConfigPage

    property alias cfg_ollamaUrl: ollamaUrl.text

    Kirigami.FormLayout {
        QQC2.TextField {
            id: ollamaUrl
            Kirigami.FormData.label: i18n("Ollama Url:")
        }
    }
}