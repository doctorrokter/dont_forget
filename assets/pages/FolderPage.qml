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
    
    signal openFolder(int taskId, string path)
    signal openList(int taskId, string path)
    signal openTask(int taskId)
    signal openContactsPage()
    
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
                    
                    onOpenFolder: {
                        root.openFolder(taskId, root.path);
                    }
                    
                    onOpenList: {
                        root.openList(taskId, root.path);
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
    }
    
    attachedObjects: [
        CustomTitleBar {
            id: defaultTitleBar
            title: root.name
            imageSource: "asset:///images/ic_folder.png"
        },
        
        TaskTitleBar {
            id: taskTitleBar
            taskId: root.taskId
            
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
    
    actions: [
        ActionItem {
            id: createFolderActionItem
            imageSource: "asset:///images/ic_add_folder.png"
            title: qsTr("Create folder") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                taskTitleBar.taskType = Const.TaskTypes.FOLDER;
            }
            
            shortcuts: [
                Shortcut {
                    key: "f"
                    
                    onTriggered: {
                        createFolderActionItem.triggered();
                    }
                }
            ]
        },
        
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
            id: createListActionItem
            imageSource: "asset:///images/ic_notes.png"
            title: qsTr("Create list") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                taskTitleBar.taskType = Const.TaskTypes.LIST;
            }
            
            shortcuts: [
                Shortcut {
                    key: "l"
                    
                    onTriggered: {
                        createListActionItem.triggered();
                    }
                }
            ]
        },
        
        ActionItem {
            id: editFolder
            imageSource: "asset:///images/ic_compose.png"
            title: qsTr("Edit") + Retranslate.onLocaleOrLanguageChanged
            
            onTriggered: {
                root.openTask(root.taskId);
            }
            
            shortcuts: [
                Shortcut {
                    key: "e"
                    
                    onTriggered: {
                        editFolder.triggered();
                    }
                }
            ]
        }
    ]
}
