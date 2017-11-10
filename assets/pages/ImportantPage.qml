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
    
    titleBar: CustomTitleBar {
        title: qsTr("Important") + Retranslate.onLocaleOrLanguageChanged
    }
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        Container {
            layout: DockLayout {}
            
            ImageView {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scalingMethod: ScalingMethod.AspectFill
                imageSource: _ui.backgroundImage
            }
            
            ListView {
                id: listView
                
                scrollRole: ScrollRole.Main
                
                dataModel: GroupDataModel {
                    id: dataModel
                    
                    sortingKeys: ["parent_id"]
                }
                
                layout: StackListLayout {
                    headerMode: ListHeaderMode.Sticky
                }
                
                function removeById(taskId, indexPath) {
                    dataModel.removeAt(indexPath);
                    _tasksService.deleteTask(taskId);
                }
                
                function openFolder(taskId) {
                    root.openFolder(taskId);
                }
                
                function openList(taskId) {
                    root.openList(taskId);
                }
                
                function openTask(taskId) {
                    root.openTask(taskId);
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
                
                contextActions: [
                    ActionSet {
                        DeleteActionItem {
                            id: deleteTask
                            
                            onTriggered: {
                                var indexPath = listView.selected();
                                var data = dataModel.data(indexPath);
                                dataModel.removeAt(indexPath);
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
                    },
                    
                    ActionSet {
                        title: qsTr("Integration") + Retranslate.onLocaleOrLanguageChanged
                        ActionItem {
                            id: openCalendar
                            title: qsTr("Open in Calendar") + Retranslate.onLocaleOrLanguageChanged
                            imageSource: "asset:///images/ic_calendar.png"
                            enabled: {
                                var indexPath = listView.selected();
                                var data = dataModel.data(indexPath);
                                return (data.type === Const.TaskTypes.LIST || data.type === Const.TaskTypes.TASK) && data.calendar_id !== 0;
                            }
                            
                            onTriggered: {
                                var indexPath = listView.selected();
                                var data = dataModel.data(indexPath);
                                _app.openCalendarEvent(data.calendar_id, data.folder_id, data.account_id);
                            }
                        }
                        
                        ActionItem {
                            id: openRemember
                            title: qsTr("Open in Remember") + Retranslate.onLocaleOrLanguageChanged
                            imageSource: "asset:///images/ic_notes.png"
                            enabled: {
                                var indexPath = listView.selected();
                                var data = dataModel.data(indexPath);
                                return (data.type === Const.TaskTypes.LIST || data.type === Const.TaskTypes.TASK) && data.remember_id !== 0;
                            }
                            
                            onTriggered: {
                                var indexPath = listView.selected();
                                var data = dataModel.data(indexPath);
                                _app.openRememberNote(data.remember_id);
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
            }
        }
    }
    
    function reload() {
        dataModel.clear();
        var tasks = _tasksService.findImportantTasks().map(function(task) {
            if (task.parent_id === "") {
                task.parent_id = -1;
            }
            return task;
        });
        dataModel.insertList(tasks);
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
