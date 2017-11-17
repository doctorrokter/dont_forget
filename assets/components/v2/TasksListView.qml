import bb.cascades 1.4
import "../../js/Const.js" as Const

ListView {
    id: listView
    
    property string path: "/"
    property int taskId: 0
    
    signal openFolder(int taskId, string path)
    signal openList(int taskId, string path)
    signal openTask(int taskId)
    
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
                    root.addEmptyItem();
                } else {
                    root.removeEmptyItem();
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
                parentId: ListItemData.parent_id
                selected: _tasksService.isTaskSelected(ListItemData.id)
                
                onOpenFolder: {
                    ListItem.view.openFolder(taskId, ListItem.view.path);
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
                    ListItem.view.openList(taskId, ListItem.view.path);
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