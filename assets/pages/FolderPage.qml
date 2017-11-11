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
    
    titleBar: defaultTitleBar
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        Header {
            title: root.path
        }
        
        Container {
            layout: DockLayout {}
            
            ImageView {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scalingMethod: ScalingMethod.AspectFill
                imageSource: _ui.backgroundImage
            }
            
            Container {
                Mover {
                    taskId: root.taskId
                }
                
                ListView {
                    id: listView
                    
                    scrollRole: ScrollRole.Main
                    
                    dataModel: ArrayDataModel {
                        id: dataModel
                    }
                    
                    function itemType(data, indexPath) {
                        return data.type;
                    }
                    
                    function removeById(taskId) {
                        var i = root.taskExists(taskId);
                        if (i !== -1) {
                            dataModel.removeAt(i);
                            _tasksService.deleteTask(taskId);
                        }
                    }
                    
                    function openTask(taskId) {
                        root.openTask(taskId);
                    }
                    
                    function openFolder(taskId) {
                        root.openFolder(taskId, root.path);
                    }
                    
                    function openList(taskId) {
                        root.openList(taskId, root.path);
                    }
                    
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                if (atEnd) {
                                    listView.margin.bottomOffset = ui.du(13);
                                } else {
                                    listView.margin.bottomOffset = ui.du(0);
                                }
                            }
                        }
                    ]
                    
                    listItemComponents: [
                        ListItemComponent {
                            type: Const.TaskTypes.DIVIDER
                            DividerListItem {}    
                        },
                        
                        ListItemComponent {
                            type: Const.TaskTypes.FOLDER
                            FolderListItem {
                                taskId: ListItemData.id
                                name: ListItemData.name
                                count: ListItemData.count || 0
                                color: ListItemData.color
                                parentId: ListItemData.parent_id
                                selected: _tasksService.isTaskSelected(ListItemData.id)
                                
                                onOpenFolder: {
                                    ListItem.view.openFolder(taskId);
                                }
                            }
                        },
                        
                        ListItemComponent {
                            type: Const.TaskTypes.LIST
                            ListListItem {
                                taskId: ListItemData.id
                                name: ListItemData.name
                                count: ListItemData.count || 0
                                color: ListItemData.color
                                parentId: ListItemData.parent_id
                                deadline: ListItemData.deadline
                                closed: ListItemData.closed
                                rememberId: parseInt(ListItemData.remember_id)
                                calendarId: parseInt(ListItemData.calendar_id)
                                selected: _tasksService.isTaskSelected(ListItemData.id)
                                
                                onOpenList: {
                                    ListItem.view.openList(taskId);
                                }
                            }    
                        },
                        
                        ListItemComponent {
                            type: Const.TaskTypes.TASK
                            TaskListItem {
                                taskId: ListItemData.id
                                name: ListItemData.name
                                deadline: ListItemData.deadline
                                important: ListItemData.important
                                closed: ListItemData.closed
                                rememberId: parseInt(ListItemData.remember_id)
                                calendarId: parseInt(ListItemData.calendar_id)
                                attachments: ListItemData.attachments
                                parentId: ListItemData.parent_id
                                description: ListItemData.description
                                selected: _tasksService.isTaskSelected(ListItemData.id)
                                
                                onTaskRemoved: {
                                    ListItem.view.removeById(taskId);
                                }
                                
                                onOpenTask: {
                                    ListItem.view.openTask(taskId);
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
    
    attachedObjects: [
        CustomTitleBar {
            id: defaultTitleBar
            title: root.name
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
    
    function firstTaskIndex() {
        for (var i = 0; i < dataModel.size(); i++) {
            if (dataModel.value(i).type === Const.TaskTypes.TASK) {
                return i;
            }
        }
        return -1;
    }
    
    function taskCreated(newTask, parentId, parentParentId) {
        if (parentId === root.taskId) {
            var i = root.firstTaskIndex();
            switch (newTask.type) {
                case Const.TaskTypes.TASK:
                    if (i !== -1) {
                        dataModel.insert(i, newTask);
                    } else {
                        dataModel.append(newTask); 
                    }
                    break;
                case Const.TaskTypes.FOLDER:
                    dataModel.insert(0, newTask);
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    break;
                case Const.TaskTypes.LIST:
                    if (i === -1) {
                        dataModel.append(newTask);
                    } else {
                        dataModel.insert(i, newTask);
                    }
                    break;
            }
        } else if (parentParentId === root.taskId) {
            root.reload();
        }
    }
    
    function taskUpdated(activeTask, parentId) {
        if (parentId === root.taskId) {
            var i = root.taskExists(activeTask.id);
            if (i !== -1) {
                dataModel.replace(i, activeTask);
            }
        }
    }
    
    function taskClosedChanged(taskId, closed, parentId) {
        if (root.taskId === parentId) {
            var i = root.taskExists(taskId);
            if (i !== -1 && closed) {
                var task = Assign.invoke({}, dataModel.value(i));
                task.closed = closed;
                dataModel.removeAt(i);
                if (task.type === Const.TaskTypes.LIST) {
                    var index = firstTaskIndex();
                    if (index !== -1) {
                        dataModel.insert(index, task);
                        return;
                    }
                }
                dataModel.append(task);
            }
        }
    }
    
    function taskExists(taskId) {
        for (var i = 0; i < dataModel.size(); i++) {
            if (dataModel.value(i).id === taskId) {
                return i;
            }
        }
        return -1;
    }
    
    function taskDeleted(taskId, parentId, parentParentId) {
        if (parentParentId === root.taskId) {
            root.reload();
        }
    }
    
    function reload() {
        root.clearSelection();
        dataModel.clear();
        dataModel.append(_tasksService.findSiblings(root.taskId));
    }
    
    function clearSelection() {
        listView.clearSelection();
        for (var i = 0; i < dataModel.size(); i++) {
            var t = dataModel.value(i);
            t.selected = false;
            dataModel.replace(i, t);
        }
    }
    
    function tasksMovedInBulk(parentId) {
        root.reload();
    }
    
    function clear() {
        _tasksService.taskCreated.disconnect(root.taskCreated);
        _tasksService.taskUpdated.disconnect(root.taskUpdated);
        _tasksService.taskClosedChanged.disconnect(root.taskClosedChanged);
        _tasksService.taskDeleted.disconnect(root.taskDeleted);
        _tasksService.allTasksDeselected.disconnect(root.clearSelection);
        _tasksService.taskMovedInBulk.disconnect(root.tasksMovedInBulk);
    }
    
    onCreationCompleted: {
        _tasksService.taskCreated.connect(root.taskCreated);
        _tasksService.taskUpdated.connect(root.taskUpdated);
        _tasksService.taskClosedChanged.connect(root.taskClosedChanged);
        _tasksService.taskDeleted.connect(root.taskDeleted);
        _tasksService.allTasksDeselected.connect(root.clearSelection);
        _tasksService.taskMovedInBulk.connect(root.tasksMovedInBulk);
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
