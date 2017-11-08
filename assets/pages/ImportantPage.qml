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
                imageSource: "asset:///images/backgrounds/earth.jpg"
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
                        type: "header"    
                        CustomListItem {
                            
                            property int parentId: ListItemData

                            preferredHeight: ui.du(8)
                            dividerVisible: false
                            
                            margin.topOffset: ui.du(2)
                            
                            Container {
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                background: ui.palette.plain
                                
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                
                                leftPadding: ui.du(1)
                                topPadding: ui.du(1)
                                rightPadding: ui.du(1)
                                bottomPadding: ui.du(1)
                                
                                ImageView {
                                    id: image
                                    verticalAlignment: VerticalAlignment.Center
                                    maxWidth: ui.du(6)
                                    maxHeight: ui.du(6)
                                }
                                
                                Label {
                                    id: title
                                    text: ""
                                    verticalAlignment: VerticalAlignment.Center
                                    
                                    layoutProperties: StackLayoutProperties {
                                        spaceQuota: 1
                                    }
                                }
                            }
                            
                            onParentIdChanged: {
                                if (parentId !== -1) {
                                    var task = _tasksService.findById(parentId);
                                    title.text = task.name;
                                    if (task.type === Const.TaskTypes.FOLDER) {
                                        image.imageSource = "asset:///images/ic_folder.png";
                                        if (task.color !== "") {
                                            image.filterColor = Color.create(task.color);
                                        } else {
                                            image.filterColor = ui.palette.primaryBase;
                                        }
                                    } else if (task.type === Const.TaskTypes.LIST) {
                                        image.imageSource = "asset:///images/ic_notes.png";
                                        if (task.color !== "") {
                                            image.filterColor = Color.create(task.color);
                                        } else {
                                            image.filterColor = Color.create("#B7B327");
                                        }
                                    }
                                } else {
                                    title.text = qsTr("Root") + Retranslate.onLocaleOrLanguageChanged                                    
                                }
                            }
                        }
                    },
                    
                    ListItemComponent {
                        type: "item"
                        TaskListItem {
                            taskId: ListItemData.id
                            name: ListItemData.name
                            deadline: ListItemData.deadline
                            important: ListItemData.important
                            closed: ListItemData.closed
                            rememberId: parseInt(ListItemData.remember_id)
                            calendarId: parseInt(ListItemData.calendar_id)
                            attachments: ListItemData.attachments
                            parentId: ListItemData.parent_id || 0
                            
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
    
    function clear() {
//        _tasksService.taskCreated.disconnect(root.taskCreated);
//        _tasksService.taskUpdated.disconnect(root.taskUpdated);
//        _tasksService.taskClosedChanged.disconnect(root.taskClosedChanged);
    }
    
    onCreationCompleted: {
//        _tasksService.taskCreated.connect(root.taskCreated);
//        _tasksService.taskUpdated.connect(root.taskUpdated);
//        _tasksService.taskClosedChanged.connect(root.taskClosedChanged);
        var tasks = _tasksService.findImportantTasks().map(function(task) {
            if (task.parent_id === "") {
                task.parent_id = -1;
            }
            return task;
        });
        dataModel.insertList(tasks);
    }
}
