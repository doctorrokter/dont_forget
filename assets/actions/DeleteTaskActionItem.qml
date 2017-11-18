import bb.cascades 1.4

DeleteActionItem {
    id: root
    
    property ListView listView: undefined
    
    onTriggered: {
        var lv = root.listView;
        var indexPath = lv.selected();
        var data = lv.dataModel.data(indexPath);
        if (lv.dataModel.objectName === "sorted") {
            lv.dataModel.removeAt(indexPath);
        } else {
            lv.dataModel.removeAt(indexPath[0]);
        }
        _tasksService.deleteTask(data.id);    
    }
    
    shortcuts: [
        Shortcut {
            key: "d"
            
            onTriggered: {
                root.triggered();
            }
        }
    ]
}