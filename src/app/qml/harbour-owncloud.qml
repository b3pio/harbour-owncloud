import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.owncloud 1.0
import Nemo.Notifications 1.0
import "qrc:/qml/navigation"

ApplicationWindow
{
    id: applicationWindow
    initialPage: basicAuthenticationComponent
    cover: coverPage

    BrowserCommandPageFlow {
        id: browserPageFlow
        commandQueue: browserCommandQueue
        onNotificationRequest: notify(summary, body)
    }
    OcsUserInfo {
        id: ocsUserInfo
        commandQueue: ocsCommandQueue
    }
    DaemonControl {
        id: daemonCtrl
    }
    Notification {
        id: notifier
    }
    QmlMap {
        id: directoryContents
    }

    readonly property bool isTransfering :
        (transferQueue.running || daemonCtrl.uploading)

    // Main application cover
    readonly property Component coverPage :
        Qt.createComponent("qrc:/qml/cover/CoverPage.qml",
                           Component.PreferSynchronous)

    // Application pages
    readonly property Component remoteDirDialogComponent :
        Qt.createComponent("qrc:/qml/pages/browser/RemoteDirSelectDialog.qml",
                           Component.PreferSynchronous);
    readonly property Component browserComponent :
        Qt.createComponent("qrc:/qml/pages/browser/FileBrowser.qml",
                           Component.PreferSynchronous);
    readonly property Component fileDetailsComponent :
        Qt.createComponent("qrc:/qml/pages/browser/FileDetails.qml",
                           Component.PreferSynchronous);
    readonly property Component selectionDialogComponent :
        Qt.createComponent("qrc:/sailfish-ui-set/ui/FileSelectionDialog.qml",
                           Component.PreferSynchronous);
    readonly property Component textEntryDialogComponent :
        Qt.createComponent("qrc:/sailfish-ui-set/ui/TextEntryDialog.qml",
                           Component.PreferSynchronous);
    readonly property Component authenticationEntranceComponent :
        Qt.createComponent("qrc:/qml/pages/login/Entrance.qml",
                           Component.PreferSynchronous);
    readonly property Component basicAuthenticationComponent :
        Qt.createComponent("qrc:/qml/pages/login/BasicAuthentication.qml",
                           Component.PreferSynchronous);
    readonly property Component flowAuthenticationComponent :
        Qt.createComponent("qrc:/qml/pages/login/FlowAuthentication.qml",
                           Component.PreferSynchronous);
    readonly property Component sslErrorDialogComponent :
        Qt.createComponent("qrc:/qml/pages/login/SSLErrorDialog.qml",
                           Component.PreferSynchronous)
    readonly property Component settingsPageComponent :
        Qt.createComponent("qrc:/qml/pages/SettingsPage.qml",
                           Component.PreferSynchronous)
    readonly property Component transferPageComponent :
        Qt.createComponent("qrc:/qml/pages/TransferPage.qml",
                           Component.PreferSynchronous)


    function refreshUserInfo() {
        // Skip in case there's already a userInfo command in the queue
        for (var i = 0; i < ocsCommandQueue.queue.length; i++) {
            var commandInfo = ocsCommandQueue.queue[i].info;
            if (commandInfo.type === "userInfo")
                return;
        }

        if (transferQueue.queue.length < 1) {
            ocsCommandQueue.userInfoRequest();
            ocsCommandQueue.run()
        }
    }

    function notify(summary, body) {
        if (!persistentSettings.notifications)
            return;

        notifier.previewSummary = summary
        notifier.previewBody = body
        notifier.publish();
    }

    WebDavCommandQueue {
        id: browserCommandQueue
        settings: persistentSettings
        immediate: true
    }
    WebDavCommandQueue {
        id: transferQueue
        settings: persistentSettings
        onCommandFinished: {
            var transferType = receipt.info.property("type")
            console.log("transferType " + transferType)
            var fileName = receipt.info.property("fileName")

            // Notify the user of successful or erroneous file transfers.
            // Also refresh the userInfo in case an upload was successful.
            if (transferType === "fileUpload") {
                if (receipt.finished) {
                    notify(qsTr("Upload complete"), qsTr("%1 uploaded successfully").arg(fileName))
                    refreshUserInfo()
                } else {
                    notify(qsTr("Upload failed!"), qsTr("%1 couldn't be uploaded").arg(fileName))
                }
            } else if (transferType === "fileDownload") {
                if (receipt.finished)
                    notify(qsTr("Download complete"), qsTr("%1 downloaded successfully").arg(fileName))
                else
                    notify(qsTr("Download failed!"), qsTr("%1 couldn't be downloaded").arg(fileName))
            }
        }
    }
    OcsCommandQueue {
        id: ocsCommandQueue
        settings: persistentSettings
    }

    AvatarFetcher {
        id: avatarFetcher
        commandQueue: ocsCommandQueue
        settings: ocsCommandQueue.settings
        width: 128
        height: 128
    }

    function isTransferEnqueued(remoteFilePath) {
        for(var i = 0; i < transferQueue.queue.length; i++) {
            var info = transferQueue.queue[i].info;
            if (info.property("remoteFile") === remoteFilePath) {
                return true;
            }
        }
        return false;
    }
}


