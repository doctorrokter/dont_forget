import bb.cascades 1.4

ActionItem {
    id: root
    
    property ListView listView: undefined
    property int taskId: 0
    
    title: qsTr("Send") + Retranslate.onLocaleOrLanguageChanged
    imageSource: "asset:///images/ic_send.png"
    
    onTriggered: {
        _tasksService.setActiveTask(root.taskId);
        root.listView.openContacts();
    }
}
