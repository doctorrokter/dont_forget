import bb.cascades 1.4
import chachkouski.util 1.0

ActionItem {
    id: root
    
    property ListView listView: undefined
    property variant indexPath
    
    title: qsTr("Move") + Retranslate.onLocaleOrLanguageChanged
    imageSource: "asset:///images/ic_forward.png"
    
    onTriggered: {
        root.indexPath = root.listView.selected();
        var data = root.listView.dataModel.data(indexPath);
        _tasksService.selectTask(data.id, indexPath);
        _tasksService.moveMode = true;
        timer.timeout.connect(root.select);
        timer.start();
    }
    
    shortcuts: [
        Shortcut {
            key: "m"
            
            onTriggered: {
                if (root.enabled) {
                    root.triggered();
                }
            }
        }
    ]
    
    function select() {
        root.listView.select(root.indexPath);
        timer.timeout.disconnect(root.select);    
    }
    
    attachedObjects: [
        Timer {
            id: timer
            
            interval: 100
            singleShot: true
        }
    ]
  }