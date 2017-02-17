/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.4
import bb.system 1.2
import "../components"
import "../pages"
import "../sheets"

NavigationPane {
    id: navigation
    
    Menu.definition: MenuDefinition {
        settingsAction: SettingsActionItem {
            onTriggered: {
                var sp = settingsPage.createObject(this);
                navigation.push(sp);
                Application.menuEnabled = false;
            }
        }
        
        helpAction: HelpActionItem {
            onTriggered: {
                var hp = helpPage.createObject(this);
                navigation.push(hp);
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
    
    onPopTransitionEnded: {
        Application.menuEnabled = true;
    }
    
    Page {
        id: main
        
        property variant viewModes: {
            SHOW_ALL: "SHOW_ALL",
            HIDE_CLOSED: "HIDE_CLOSED"
        }
        property string viewMode: viewModes.SHOW_ALL
        
        
        titleBar: titleBar
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Overlay
        
        Container {
            
            layout: DockLayout {}
            
            Container {
                id: noTasksContainer
                visible: false
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Label {
                    text: qsTr("You have no tasks yet. It's time to create new one!") + Retranslate.onLocaleOrLanguageChanged
                    multiline: true
                }
            }
            
            ScrollView {
                id: scrollView
                
                property double pinchDistance: 0
                
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                scrollRole: ScrollRole.Main
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.TopToBottom
                    }
                    
                    Container {
                        id: tasksContainer
                        objectName: "tasks_container"
                        horizontalAlignment: HorizontalAlignment.Fill
                    }
                    
                    Container {
                        horizontalAlignment: HorizontalAlignment.Fill
                        minHeight: ui.du(12)
                    }
                }
                
                gestureHandlers: [
                    PinchHandler {
                        onPinchStarted: {
                            scrollView.pinchDistance = event.distance;
                        }
                        
                        onPinchEnded: {
                            if (event.distance < scrollView.pinchDistance) {
                                _tasksService.unexpandAll();
                            } else {
                                _tasksService.expandAll();
                            }
                            scrollView.pinchDistance = 0;
                        }
                    }
                ]
            }
        }
        
        actions: [
            ActionItem {
                id: createActionItem
                title: qsTr("Create") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_add.png"
                ActionBar.placement: ActionBarPlacement.Signature
                
                onTriggered: {
                    taskSheet.mode = taskSheet.modes.CREATE;
                    taskSheet.open();
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                        
                        onTriggered: {
                            createActionItem.triggered();
                        }
                    }
                ]
            },
            
            ActionItem {
                id: editActionItem
                enabled: _tasksService.activeTask !== null;
                title: qsTr("Edit") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_compose.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    taskSheet.mode = taskSheet.modes.UPDATE;
                    taskSheet.open();
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.Edit
                        
                        onTriggered: {
                            if (editActionItem.enabled) {
                                editActionItem.triggered();
                            }
                        }
                    }
                ]
            },
                        
            DeleteActionItem {
                id: deleteActionItem
                
                enabled: _tasksService.activeTask !== null;
                title: qsTr("Delete") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_delete.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
                    if (doNotAsk && doNotAsk === "true") {
                        var id = _tasksService.activeTask.id;
                        _tasksService.deleteTask(id);
                        deleteTask(id, tasksContainer);
                    } else {
                        deleteTaskDialog.open();
                    }
                }
                
                shortcuts: [
                    Shortcut {
                        key: "d"
                        
                        onTriggered: {
                            if (deleteActionItem.enabled) {
                                deleteActionItem.triggered();
                            }
                        }
                    }
                ]
            },
            
            ActionItem {
                title: {
                    if (main.viewMode === main.viewModes.SHOW_ALL) {
                        return qsTr("Hide closed") + Retranslate.onLocaleOrLanguageChanged;
                    }
                    return qsTr("Show all") + Retranslate.onLocaleOrLanguageChanged;
                }
                imageSource: "asset:///images/ic_done_all.png"
                
                onTriggered: {
                    if (main.viewMode === main.viewModes.SHOW_ALL) {
                        _tasksService.changeViewMode(main.viewModes.HIDE_CLOSED);
                    } else {
                        _tasksService.changeViewMode(main.viewModes.SHOW_ALL);
                    }
                }
            },
            
            ActionItem {
                id: moveActionItem
                title: qsTr("Move") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_forward.png"
                enabled: _tasksService.activeTask !== null;
                
                onTriggered: {
                    var mtp = moveTaskPage.createObject(this);
                    navigation.push(mtp);
                }
                
                shortcuts: [
                    Shortcut {
                        key: "m"
                        
                        onTriggered: {
                            if (moveActionItem.enabled) {
                                moveActionItem.triggered();
                            }
                        }
                    }
                ]
            },
            
            ActionItem {
                id: sentActionItem
                title: qsTr("Send") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    _pushService.pushMessageToUser("2AB9B718", 2, "Test", "Test message");
                }
            }
        ]
        
        attachedObjects: [
            CustomTitleBar {
                id: titleBar
                title: qsTr("All Tasks") + Retranslate.onLocaleOrLanguageChanged
                clearable: _tasksService.activeTask !== null && _tasksService.activeTask !== undefined;
            },
            
            ComponentDefinition {
                id: settingsPage
                SettingsPage {
                    onSortByChanged: {
                        navigation.renderTree();
                    }
                }
            },
            
            ComponentDefinition {
                id: helpPage
                HelpPage {}
            },
            
            ComponentDefinition {
                id: moveTaskPage
                TasksListPage {
                    onTaskChosen: {
                        if (_tasksService.activeTask.parentId !== chosenTask.id) {
                            _tasksService.moveTask(chosenTask.id);
                        }
                        navigation.pop();
                    }
                }
            },
            
            ComponentDefinition {
                id: taskComponent
                Task {}    
            },
            ComponentDefinition {
                id: divider
                Divider {}
            },
            TaskSheet {
                id: taskSheet
            },
            
            Invocation {
                id: invoke
                query {
                    uri: "mailto:dontforget.bbapp@gmail.com?subject=Don't%20Forget:%20Feedback"
                    invokeActionId: "bb.action.SENDEMAIL"
                    invokeTargetId: "sys.pim.uib.email.hybridcomposer"
                }
            },
            
            Invocation {
                id: permissionSettings
                query {
                    uri: "settings://permissions"
                    invokeActionId: "bb.action.OPEN"
                    invokeTargetId: "sys.settings.target"
                    mimeType: "settings/view"
                }
            },
            
            SystemDialog {
                id: permissionDialog
                title: qsTr("Permission required") + Retranslate.onLocaleOrLanguageChanged
                body: qsTr("Looks like you didn't grant permission for shared files. \"Don't Forget\" cannot work without this permission since " +
                           "the app stores own database in external resources. In order to use this app you should grant permissions in Settings, then restart the app.") + Retranslate.onLocaleOrLanguageChanged
                  
                cancelButton.label: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged
                           
                onFinished: {
                    if (value === SystemUiResult.ConfirmButtonSelection) {
                        exit();
                    } else {
                        exit();
                        permissionSettings.trigger(permissionSettings.query.invokeActionId);
                    }
                }
                
                function exit() {
                    Application.aboutToQuit();
                    Application.quit();
                }
            },
            
            DeleteTaskDialog {
                id: deleteTaskDialog
                
                onConfirm: {
                    var id = _tasksService.activeTask.id;
                    _tasksService.deleteTask(id);
                    deleteTask(id, tasksContainer);
                }
            }
        ]
        
        function updateTitleBar() {
            if (_tasksService.activeTask && _tasksService.activeTask !== null) {
                titleBar.title = _tasksService.activeTask.name;
            } else {
                titleBar.title = qsTr("All Tasks") + Retranslate.onLocaleOrLanguageChanged;
            }
        }
        
        function changeViewMode(viewMode) {
            main.viewMode = viewMode;
        }
        
        onCreationCompleted: {
            if (!_tasksService.hasSharedFilesPermission) {
                permissionDialog.show();
            }
            _tasksService.activeTaskChanged.connect(main.updateTitleBar);
            _tasksService.viewModeChanged.connect(main.changeViewMode);
        }
    }
    
    function onTaskCreated(newTask) {
        newTask.children = [];
        noTasksContainer.visible = false;
        createTask(newTask, tasksContainer);
    }   
    
    function createTask(newTask, parent) {
        if (newTask.parent_id === "" || newTask.parent_id === "NULL") {
            addTask(parent, newTask);
        } else {
            if (parent.objectName === "task_" + newTask.parent_id) {
                addTask(parent, newTask);
            } else {
                if (parent.controls) {
                    for (var i = 0; i < parent.controls.length; i++) {
                        createTask(newTask, parent.controls[i]);
                    }
                }
            }
        }
    }
    
    function deleteTask(id, parent) {
        if (parent.objectName === "task_" + id) {
            parent.parent.remove(parent);
        } else {
            if (parent.controls) {
                for (var i = 0; i < parent.controls.length; i++) {
                    deleteTask(id, parent.controls[i]);
                }
            }
        }
    }
    
    function deleteAllTasks() {
        while(tasksContainer.controls.length !== 0) {
            tasksContainer.remove(tasksContainer.controls[tasksContainer.controls.length - 1]);
        }
    }
    
    function addTask(parent, t) {
        var newTask = taskComponent.createObject(parent);
        newTask.name = t.name;
        newTask.type = t.type;
        newTask.taskId = t.id;
        newTask.expandable = (t.children.length !== 0) || t.type === "FOLDER";
        newTask.expanded = t.expanded;
        newTask.closed = t.closed;
        newTask.important = t.important;
        newTask.deadline = t.deadline;
        newTask.rememberId = t.remember_id;
        newTask.parentId = t.parent_id;
        
        if (parent.objectName === "tasks_container") {
            parent.add(newTask);
        } else {
            parent.addChildTask(newTask);
        }
        
        
        t.children.forEach(function(t1) {
            addTask(newTask, t1);
        });
    }
    
    function children(allTasks, root) {
        var r = root;
        root.children = allTasks.filter(function(task) {
            return task.parent_id === root.id;
        });
        if (root.children.length !== 0) {
            root.children.forEach(function (task) {
                children(allTasks, task);
            });
        }
    }
    
    function renderTree() {
        deleteAllTasks();
        
        var allTasks = _tasksService.findAll();
        if (allTasks.length === 0) {
            noTasksContainer.visible = true;
        } else {
            noTasksContainer.visible = false;
            var roots = allTasks.filter(function(task) {
                    return task.parent_id === "" || task.parent_id === "NULL";     
            });
        
            roots.forEach(function(root) {
                children(allTasks, root);  
            });
    
            roots.forEach(function(t) {
                addTask(tasksContainer, t);
            });
        }
    }
    
    function openTaskSheetEditMode() {
        taskSheet.mode = taskSheet.modes.UPDATE;
        taskSheet.open();
    }
    
    onCreationCompleted: {
        renderTree();
        _tasksService.taskCreated.connect(navigation.onTaskCreated);
        _tasksService.taskMoved.connect(navigation.renderTree);
        _app.taskSheetRequested.connect(navigation.openTaskSheetEditMode);
    }
}
