import bb.cascades 1.4
import bb.system 1.2
import "./components"
import "./components/v2"
import "./pages"
import "./js/Const.js" as Const

NavigationPane {
    
    id: navigationPane
    
    Menu.definition: MenuDefinition {
        settingsAction: SettingsActionItem {
            onTriggered: {
                var sp = settingsPage.createObject();
                navigationPane.push(sp);
                Application.menuEnabled = false;
            }
        }
        
        helpAction: HelpActionItem {
            onTriggered: {
                var hp = helpPage.createObject();
                navigationPane.push(hp);
                Application.menuEnabled = false;
            }
        }
        
        actions: [
            ActionItem {
                title: qsTr("Send feedback") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_feedback.png"
                
                onTriggered: {
                    invoke.trigger(invoke.query.invokeActionId);
                }
            }
        ]
    }
    
    Page {
        id: root
        
        titleBar: defaultTitleBar
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Overlay
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            
            layout: DockLayout {}
            
            background: ui.palette.plainBase
            
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
                    _tasksService.setActiveTask(taskId);
                    var tp = taskPage.createObject();
                    navigationPane.push(tp);
                }
                
                function openFolder(taskId, taskName) {
                    var fp = folderPage.createObject();
                    fp.name = taskName;
                    fp.path = "/" + taskName;
                    fp.taskId = taskId;
                    navigationPane.push(fp);
                }
                
                function openList(taskId, taskName) {
                    var lp = listPage.createObject();
                    lp.name = taskName;
                    lp.path = "/" + taskName;
                    lp.taskId = taskId;
                    navigationPane.push(lp);
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
                                if (data.type !== Const.TaskTypes.RECEIVED && 
                                    data.type !== Const.TaskTypes.TODAY && 
                                    data.type !== Const.TaskTypes.IMPORTANT) {
                                        dataModel.removeAt(dataModel.indexOf(data));
                                        _tasksService.deleteTask(data.id);    
                                }
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
                        type: Const.TaskTypes.RECEIVED
                        ReceivedListItem {
                            count: ListItemData.count
                        }
                    },
                    
                    ListItemComponent {
                        type: Const.TaskTypes.TODAY
                        TodayListItem {
                            count: ListItemData.count
                        }
                    },
                    
                    ListItemComponent {
                        type: Const.TaskTypes.IMPORTANT
                        ImportantListItem {
                            count: ListItemData.count
                        }
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
                            parentId: ListItemData.parent_id || 0
                            
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
                            parentId: ListItemData.parent_id || 0
                            deadline: ListItemData.deadline
                            closed: ListItemData.closed
                            rememberId: parseInt(ListItemData.remember_id)
                            calendarId: parseInt(ListItemData.calendar_id)
                            
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
                            parentId: ListItemData.parent_id || 0
                            description: ListItemData.description
                            
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
        
        function taskExists(taskId) {
            for (var i = 0; i < dataModel.size(); i++) {
                if (dataModel.value(i).id === taskId) {
                    return i;
                }
            }
            return -1;
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
            if (parentId === 0) {
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
                        dataModel.insert(3, newTask);
                        break;
                    case Const.TaskTypes.LIST:
                        if (i === -1) {
                            dataModel.append(newTask);
                        } else {
                            dataModel.insert(i, newTask);
                        }
                        break;
                }
            } else if (parentParentId === 0) {
                root.reload();
            }
        }
        
        function taskUpdated(activeTask, parentId) {
            navigationPane.pop();
            if (parentId === 0) {
                var i = root.taskExists(activeTask.id);
                if (i !== -1) {
                    dataModel.replace(i, activeTask);
                }
            }
        }
        
        function taskClosedChanged(taskId, closed, parentId) {
            if (parentId === 0) {
                var i = root.taskExists(taskId);
                if (i !== -1 && closed) {
                    var task = dataModel.value(i);
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
        
        function taskDeleted(taskId, parentId, parentParentId) {
            if (parentId !== 0) {
                root.reload();
            }
        }
        
        function reload() {
            dataModel.clear();
            var data = [];
            data.push({count: 0, type: Const.TaskTypes.RECEIVED});
            data.push({count: 0, type: Const.TaskTypes.TODAY});
            data.push({count: 0, type: Const.TaskTypes.IMPORTANT});
            data.push({type: "DIVIDER"});
            dataModel.append(data);
            dataModel.append(_tasksService.findSiblings());
        }
        
        onCreationCompleted: {
            root.reload();
            
            _tasksService.taskCreated.connect(root.taskCreated);
            _tasksService.taskUpdated.connect(root.taskUpdated);
            _tasksService.taskClosedChanged.connect(root.taskClosedChanged);
            _tasksService.taskDeleted.connect(root.taskDeleted);
            _app.folderPageRequested.connect(root.openFolderPage)
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
                imageSource: "asset:///images/ic_view_list.png"
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
            }
        ]
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: settingsPage
            SettingsPage {}
        },
        
        ComponentDefinition {
            id: helpPage
            HelpPage {}
        },
        
        ComponentDefinition {
            id: folderPage
            FolderPage {
                onOpenFolder: {
                    var fp = folderPage.createObject();
                    var folder = _tasksService.findById(taskId);
                    fp.path = path + "/" + folder.name;
                    fp.name = folder.name;
                    fp.taskId = taskId;
                    navigationPane.push(fp);
                }
                
                onOpenList: {
                    var list = _tasksService.findById(taskId);
                    var lp = listPage.createObject();
                    lp.name = list.name;
                    lp.path = path + "/" + list.name;
                    lp.taskId = taskId;
                    navigationPane.push(lp);
                }
                
                onOpenTask: {
                    _tasksService.setActiveTask(taskId);
                    var tp = taskPage.createObject();
                    navigationPane.push(tp);
                }
            }    
        },
        
        ComponentDefinition {
            id: listPage
            ListPage {
                onOpenTask: {
                    _tasksService.setActiveTask(taskId);
                    var tp = taskPage.createObject();
                    navigationPane.push(tp);
                }
            }    
        },
        
        ComponentDefinition {
            id: taskPage
            TaskPage {}    
        },
        
        Invocation {
            id: invoke
            query {
                uri: "mailto:dontforget.bbapp@gmail.com?subject=Don't%20Forget:%20Feedback"
                invokeActionId: "bb.action.SENDEMAIL"
                invokeTargetId: "sys.pim.uib.email.hybridcomposer"
            }
        },
        
        CustomTitleBar {
            id: defaultTitleBar
            title: qsTr("Dashboard") + Retranslate.onLocaleOrLanguageChanged
        },
        
        TaskTitleBar {
            id: taskTitleBar
            taskId: 0
            
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
    
    onPopTransitionEnded: {
        Application.menuEnabled = true;
        if (page.clear) {
            page.clear();
        }
        page.destroy();
    }
}
