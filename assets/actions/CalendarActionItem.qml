import bb.cascades 1.4

ActionItem {
    id: root
    
    property ListView listView: undefined
    
    title: qsTr("Open in Calendar") + Retranslate.onLocaleOrLanguageChanged
    imageSource: "asset:///images/ic_calendar.png"
    
    onTriggered: {
        var indexPath = root.listView.selected();
        var data = root.listView.dataModel.data(indexPath);
        _app.openCalendarEvent(data.calendar_id, data.folder_id, data.account_id);
    }
}