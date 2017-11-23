import bb.cascades 1.4
import "../components"
import "../components/v2"
import "../js/Const.js" as Const

Page {
    id: root
    
    property string name: ""
    property string path: "/"
    property int taskId: 0
    
    signal openFolder(int taskId)
    signal openList(int taskId)
    signal openTask(int taskId)
    signal openContactsPage()
    
    titleBar: CustomTitleBar {
        title: qsTr("Today") + Retranslate.onLocaleOrLanguageChanged
        imageSource: "asset:///images/ic_calendar.png"
    }
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        BackgroundContainer {
            SortedListView {
                id: listView
                
                onOpenFolder: {
                    root.openFolder(taskId);
                }
                
                onOpenList: {
                    root.openList(taskId);
                }
                
                onOpenTask: {
                    root.openTask(taskId);
                }
                
                onOpenContactsPage: {
                    root.openContactsPage();
                }
            }
        }
    }
    
    function reload() {
        listView.clear();
        var tasks = _tasksService.findTodayTasks().map(function(task) {
            if (task.parent_id === "") {
                task.parent_id = -1;
            }
            return task;
        });
        listView.insertList(tasks);
    }
    
    function clear() {
        _tasksService.taskDeleted.disconnect(root.reload);
        _tasksService.taskUpdated.disconnect(root.reload);
    }
    
    onCreationCompleted: {
        _tasksService.taskDeleted.connect(root.reload);
        _tasksService.taskUpdated.connect(root.reload);
        reload();
    }
}
