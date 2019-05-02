import QtQuick 2.4
import QtQuick.Controls 2.0
import Ubuntu.Content 1.3

Page {
    id: pageRoot
    title: qsTr("Open '%1' with").arg(fileName)

    readonly property bool destroyable : true

    property string fileUri : null
    readonly property string fileName : fileUri.substring(fileUri.lastIndexOf('/') + 1)

    property var activeTransfer
    Connections {
        target: pageRoot.activeTransfer
        onStateChanged: {
            exportContent(pageRoot.fileUri)
        }
    }

    Component {
        id: resultComponent
        ContentItem {}
    }

    function exportContent(url) {
        if (pageRoot.activeTransfer.state !== ContentTransfer.InProgress)
            return;

        pageRoot.activeTransfer.items = [ resultComponent.createObject(pageRoot,
                                                                       {"url": url})];
        pageRoot.activeTransfer.state = ContentTransfer.Charged;
    }

    ContentPeerPicker {
        id: peerPicker
        showTitle: false

        handler: ContentHandler.Destination
        contentType: ContentType.All

        onPeerSelected: {
            pageRoot.activeTransfer = peer.request();
            detailsStack.pop();
            exportContent(pageRoot.fileUri)
        }

        onCancelPressed: {
            detailsStack.pop();
        }
    }
}
