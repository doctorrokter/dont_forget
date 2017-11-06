import bb.cascades 1.4
import "../components"
import "../components/v2"
import "../js/Const.js" as Const

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
    
        Container {
            layout: DockLayout {}
    
            ImageView {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scalingMethod: ScalingMethod.AspectFill
                imageSource: "asset:///images/backgrounds/BeautifulViewWallpaper(Wall2mob.com)_38808.jpg"
            }
            
            ListView {
                id: listView
                
                scrollRole: ScrollRole.Main
                
                dataModel: ArrayDataModel {
                    id: dataModel
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
                
                contextActions: [
                    ActionSet {
                        DeleteActionItem {
                            id: deleteTask
                            
                            onTriggered: {
                                var indexPath = listView.selected();
                                var data = dataModel.data(indexPath);
                                dataModel.removeAt(dataModel.indexOf(data));
                                _tasksService.deleteTask(data.id);    
                            }
                            
                            shortcuts: [
                                Shortcut {
                                    key: "d"
                                    
                                    onTriggered: {
                                        deleteTask.triggered();
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                listItemComponents: [
                    ListItemComponent {
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
            dataModel.insert(0, newTask);
        }
    }
    
    function taskUpdated(activeTask, parentId) {
        if (parentId === root.taskId) {
            var i = root.taskExists(activeTask.id);
            if (i !== -1) {
                dataModel.replace(i, activeTask);
            }
        } else if (activeTask.id === root.taskId) {
            root.path = root.path.replace(root.name, activeTask.name);
            root.name = activeTask.name;
        }
    }
    
    function taskClosedChanged(taskId, closed, parentId) {
        if (root.taskId === parentId) {
            var i = root.taskExists(taskId);
            if (i !== -1 && closed) {
                var task = dataModel.value(i);
                dataModel.removeAt(i);
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
    
    function reload() {
        dataModel.clear();
        dataModel.append(_tasksService.findByType(Const.TaskTypes.TASK, root.taskId));
    }
    
    function clear() {
        _tasksService.taskCreated.disconnect(root.taskCreated);
        _tasksService.taskUpdated.disconnect(root.taskUpdated);
        _tasksService.taskClosedChanged.disconnect(root.taskClosedChanged);
    }
    
    onTaskIdChanged: {
        taskTitleBar.taskId = taskId;
        root.reload();
    }
    
    onCreationCompleted: {
        _tasksService.taskCreated.connect(root.taskCreated);
        _tasksService.taskUpdated.connect(root.taskUpdated);
        _tasksService.taskClosedChanged.connect(root.taskClosedChanged);
    }
}
