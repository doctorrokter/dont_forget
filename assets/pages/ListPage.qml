import bb.cascades 1.4
import "../actions"
import "../components"
import "../components/v2"
import "../js/Const.js" as Const
import "../js/assign.js" as Assign

Page {
    id: root
    
    property string name: ""
    property string path: "/"
    property int taskId: 0
    
    signal openTask(int taskId)
    
    titleBar: defaultTitleBar
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
    
        Header {
            title: root.path
        }
    
        BackgroundContainer {
            MoverContainer {
                taskId: root.taskId
                UnsortedListView {
                    id: listView
                    
                    taskId: root.taskId
                    
                    onReload: {
                        root.reload();
                    }
                    
                    onOpenTask: {
                        root.openTask(taskId);
                    }
                }
            }
        }
    }
    
    actions: [
        ActionItem {
            id: createTaskActionItem
            imageSource: "asset:///images/ic_add.png"
            title: qsTr("Create task") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.Signature
            
            onTriggered: {
                taskTitleBar.taskType = Const.TaskTypes.TASK;
            }
            
            shortcuts: [
                Shortcut {
                    key: "c"
                    
                    onTriggered: {
                        createTaskActionItem.triggered();
                    }
                }
            ]
        },
        
        ActionItem {
            id: editList
            imageSource: "asset:///images/ic_compose.png"
            title: qsTr("Edit") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                root.openTask(root.taskId);
            }
            
            shortcuts: [
                Shortcut {
                    key: "e"
                    
                    onTriggered: {
                        editList.triggered();
                    }
                }
            ]
        }
    ]
    
    attachedObjects: [
        CustomTitleBar {
            id: defaultTitleBar
            title: root.name
            imageSource: "asset:///images/ic_notes.png"
        },
        
        TaskTitleBar {
            id: taskTitleBar
            
            onSubmit: {
                root.titleBar = defaultTitleBar;
            }
            
            onTaskTypeChanged: {
                if (taskType !== "") {
                    root.titleBar = taskTitleBar;
                    focus();
                }
            }
            
            onCancel: {
                root.titleBar = defaultTitleBar;
            }
        }
    ]
    
    function reload() {
        listView.flushSelection();
        listView.flush();
        listView.append(_tasksService.findSiblings(root.taskId));
    }
    
    function clear() {
        listView.clean();
    }
    
    onTaskIdChanged: {
        taskTitleBar.taskId = taskId;
        root.reload();
    }
}
