import bb.cascades 1.4

ActionItem {
    id: root
    
    property ListView listView: undefined
    
    title: qsTr("Open in Remember") + Retranslate.onLocaleOrLanguageChanged
    imageSource: "asset:///images/ic_notes.png"
    
    onTriggered: {
        var indexPath = root.listView.selected();
        var data = root.listView.dataModel.data(indexPath);
        _app.openRememberNote(data.remember_id);
    }
}
