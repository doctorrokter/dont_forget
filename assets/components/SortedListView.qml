import bb.cascades 1.4
import "./v2/"
import "../js/Const.js" as Const

ListView {
    id: listView
    
    signal openFolder(int taskId)
    signal openList(int taskId)
    signal openTask(int taskId)
    
    scrollRole: ScrollRole.Main
    
    dataModel: GroupDataModel {
        id: dataModel
        objectName: "sorted"
        
        sortingKeys: ["parent_id"]
    }
    
    layout: StackListLayout {
        headerMode: ListHeaderMode.Sticky
    }
    
    function removeById(taskId, indexPath) {
        dataModel.removeAt(indexPath);
        _tasksService.deleteTask(taskId);
    }
    
    function itemType(data, indexPath) {
        if (indexPath.length === 1) {
            return "header";
        }
        return "item";
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
            type: "header" 
            ListItemTaskHeader {
                parentId: ListItemData
                
                onOpenFolder: {
                    ListItem.view.openFolder(taskId);
                }
                
                onOpenList: {
                    ListItem.view.openList(taskId);
                }
            }   
        },
        
        ListItemComponent {
            type: "item"
            TaskListItem {
                taskId: ListItemData.id
                name: ListItemData.name
                description: ListItemData.description
                deadline: ListItemData.deadline
                important: ListItemData.important
                closed: ListItemData.closed
                rememberId: parseInt(ListItemData.remember_id)
                calendarId: parseInt(ListItemData.calendar_id)
                attachments: ListItemData.attachments
                parentId: ListItemData.parent_id || 0
                
                onTaskRemoved: {
                    ListItem.view.removeById(taskId, ListItem.indexPath);
                }
                
                onOpenTask: {
                    ListItem.view.openTask(taskId);
                }
            }
        }
    ]
    
    function clear() {
        dataModel.clear();
    }
    
    function insertList(items) {
        dataModel.insertList(items);
    }
    
}
