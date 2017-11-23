import bb.cascades 1.4
import "./v2/"
import "../js/Const.js" as Const
import "../js/assign.js" as Assign

ListView {
    id: listView
    
    property int taskId: 0
    
    signal openFolder(int taskId, string name)
    signal openList(int taskId, string name)
    signal openTask(int taskId)
    signal reload()
    signal openContactsPage()
    
    scrollRole: ScrollRole.Main
    
    dataModel: ArrayDataModel {
        id: dataModel
    }
    
    function itemType(data, indexPath) {
        return data.type;
    }
    
    attachedObjects: [
        ListScrollStateHandler {
            onAtEndChanged: {
                if (atEnd) {
                    listView.addEmptyItem();
                } else {
                    listView.removeEmptyItem();
                }
            }
        }
    ]
    
    listItemComponents: [
        ListItemComponent {
            type: Const.TaskTypes.EMPTY
            EmptyListItem {}  
        },
        
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
                parentId: ListItemData.parent_id === "" ? 0 : ListItemData.parent_id
                selected: _tasksService.isTaskSelected(ListItemData.id)
                
                onOpenFolder: {
                    ListItem.view.openFolder(taskId, name);
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
                parentId: ListItemData.parent_id === "" ? 0 : ListItemData.parent_id
                deadline: ListItemData.deadline
                closed: ListItemData.closed
                rememberId: parseInt(ListItemData.remember_id)
                calendarId: parseInt(ListItemData.calendar_id)
                selected: _tasksService.isTaskSelected(ListItemData.id)
                
                onOpenList: {
                    ListItem.view.openList(taskId, name);
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
                parentId: ListItemData.parent_id === "" ? 0 : ListItemData.parent_id
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
    
    function removeById(taskId) {
        var i = listView.taskExists(taskId);
        if (i !== -1) {
            dataModel.removeAt(i);
            _tasksService.deleteTask(taskId);
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
    
    function addEmptyItem() {
        var data = dataModel.value(dataModel.size() - 1);
        if (data !== undefined && data.type !== Const.TaskTypes.EMPTY) {
            dataModel.append({type: Const.TaskTypes.EMPTY});
        }
    }
    
    function removeEmptyItem() {
        var data = dataModel.value(dataModel.size() - 1);
        if (data !== undefined && data.type === Const.TaskTypes.EMPTY) {
            dataModel.removeAt(dataModel.size() - 1);
        }
    }
    
    function flush() {
        dataModel.clear();
    }
    
    function append(items) {
        dataModel.append(items);
    }
    
    function flushSelection() {
        listView.clearSelection();
        for (var i = 0; i < dataModel.size(); i++) {
            var t = dataModel.value(i);
            t.selected = false;
            dataModel.replace(i, t);
        }
    }
    
    function firstTaskIndex() {
        for (var i = 0; i < dataModel.size(); i++) {
            if (dataModel.value(i).type === Const.TaskTypes.TASK) {
                return i;
            }
        }
        return -1;
    }
    
    function taskCreated(newTask, parentId, parentParentId) {
        if (parentId === listView.taskId) {
            listView.removeEmptyItem();
            var i = listView.firstTaskIndex();
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
                    break;
                case Const.TaskTypes.LIST:
                    if (i === -1) {
                        dataModel.append(newTask);
                    } else {
                        dataModel.insert(i, newTask);
                    }
                    break;
            }
            listView.scrollToPosition(i, ScrollAnimation.Smooth);
        } else if (parentParentId === listView.taskId) {
            listView.reload();
        }
    }
    
    function taskUpdated(activeTask, parentId) {
        if (parentId === listView.taskId) {
            var i = listView.taskExists(activeTask.id);
            if (i !== -1) {
                dataModel.replace(i, activeTask);
            }
        }
    }
    
    function taskClosedChanged(taskId, closed, parentId) {
        if (listView.taskId === parentId) {
            var i = listView.taskExists(taskId);
            if (i !== -1 && closed) {
                var task = Assign.invoke({}, dataModel.value(i));
                task.closed = closed;
                dataModel.removeAt(i);
                if (task.type === Const.TaskTypes.LIST) {
                    var index = listView.firstTaskIndex();
                    if (index !== -1) {
                        dataModel.insert(index, task);
                        return;
                    }
                } else {
                    listView.removeEmptyItem();
                    dataModel.append(task);
                    return;
                }
            }
        }
    }
    
    function taskDeleted(taskId, parentId, parentParentId) {
        if (parentParentId === listView.taskId) {
            listView.reload();
        }
    }
    
    function tasksMovedInBulk(parentId) {
        listView.reload();
    }
    
    function openContacts() {
        listView.openContactsPage();
    }
    
    function clean() {
        _tasksService.taskCreated.disconnect(listView.taskCreated);
        _tasksService.taskUpdated.disconnect(listView.taskUpdated);
        _tasksService.taskClosedChanged.disconnect(listView.taskClosedChanged);
        _tasksService.taskDeleted.disconnect(listView.taskDeleted);
        _tasksService.allTasksDeselected.disconnect(listView.flushSelection);
        _tasksService.taskMovedInBulk.disconnect(listView.tasksMovedInBulk);
    }
    
    onCreationCompleted: {
        _tasksService.taskCreated.connect(listView.taskCreated);
        _tasksService.taskUpdated.connect(listView.taskUpdated);
        _tasksService.taskClosedChanged.connect(listView.taskClosedChanged);
        _tasksService.taskDeleted.connect(listView.taskDeleted);
        _tasksService.allTasksDeselected.connect(listView.flushSelection);
        _tasksService.taskMovedInBulk.connect(listView.tasksMovedInBulk);
    }
}
