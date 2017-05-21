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
import "./components"
import "./pages"
import "./sheets"

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
        if (page.clear) {
            page.clear();
        }
        page.destroy();
    }
    
    Page {
        id: main
        
        property bool searchMode: false
        property bool multiselectMode: _tasksService.multiselectMode
        property variant tasks: []
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
                
                scrollViewProperties {
                    scrollMode: ScrollMode.Vertical
                }
                
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
            
            ActivityIndicator {
                id: loading
                running: false
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                minWidth: ui.du(10);
            }
        }
        
        actions: [
            ActionItem {
                id: createActionItem
                title: qsTr("Create") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_add.png"
                ActionBar.placement: ActionBarPlacement.Signature
                enabled: !main.multiselectMode
                
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
                enabled: _tasksService.activeTask !== null && !main.multiselectMode;
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
                
                enabled: _tasksService.activeTask !== null || main.multiselectMode;
                title: qsTr("Delete") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_delete.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
                    if (doNotAsk && doNotAsk === "true") {
                        if (_tasksService.multiselectMode) {
                            var ids = _tasksService.deleteBulk();
                            ids.forEach(function(id) {
                                deleteTask(id, tasksContainer);
                            });
                        } else {
                            var id = _tasksService.activeTask.id;
                            _tasksService.deleteTask(id);
                            deleteTask(id, tasksContainer);
                        }
                    } else {
//                        deleteTaskDialog.open();
                        deleteTaskDialog.show();
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
                id: moveActionItem
                title: qsTr("Move") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_forward.png"
                enabled: _tasksService.activeTask !== null || main.multiselectMode;
                
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
                id: sendActionItem
                title: qsTr("Send") + Retranslate.onLocaleOrLanguageChanged
                enabled: _tasksService.activeTask !== null && !main.multiselectMode;
                imageSource: "asset:///images/ic_send.png"
                
                onTriggered: {
                    var contactsPage = contacts.createObject(this);
                    navigation.push(contactsPage);
                }
            },
            
            ActionItem {
                id: viewActionItem
                enabled: _tasksService.activeTask !== null && !main.multiselectMode;
                title: qsTr("View") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_watch.png"
                
                onTriggered: {
                    var viewPage = taskViewPage.createObject(this);
                    navigation.push(viewPage);
                }
                
                shortcuts: [
                    Shortcut {
                        key: "v"
                        
                        onTriggered: {
                            if (viewActionItem.enabled) {
                                viewActionItem.triggered();
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
                id: searchActionItem
                title: qsTr("Search") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_search.png"
                
                shortcuts: [
                    Shortcut {
                        key: "s"
                        
                        onTriggered: {
                            searchActionItem.triggered();
                        }
                    }
                ]
                
                onTriggered: {
                    main.searchMode = true;
                }
            },
            
            ActionItem {
                id: multiselectActionItem
                title: {
                    if (main.multiselectMode) {
                        return qsTr("Single select") + Retranslate.onLocaleOrLanguageChanged;
                    }
                    return qsTr("Select more") + Retranslate.onLocaleOrLanguageChanged;
                }
                imageSource: "asset:///images/ic_select_more.png"
                
                onTriggered: {
                    _tasksService.multiselectMode = !_tasksService.multiselectMode;
                }
            },
            
            ActionItem {
                id: openCalendar
                title: qsTr("Open in Calendar") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_calendar.png"
                enabled: _tasksService.activeTask !== null && _tasksService.activeTask.calendarId !== 0;
                
                onTriggered: {
                    _app.openCalendarEvent(_tasksService.activeTask.calendarId, _tasksService.activeTask.folderId, _tasksService.activeTask.accountId);
                }
            },
            
            ActionItem {
                id: openRemember
                title: qsTr("Open in Remember") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_notes.png"
                enabled: _tasksService.activeTask !== null && _tasksService.activeTask.rememberId !== "";
                
                onTriggered: {
                    _app.openRememberNote(_tasksService.activeTask.rememberId);
                }
            },
            
            ActionItem {
                id: openSortingDialog
                
                title: qsTr("Sort") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_sort.png"
                
                onTriggered: {
                    sortingDialog.show();
                }
                
                shortcuts: [
                    Shortcut {
                        key: "o"
                        
                        onTriggered: {
                            openSortingDialog.triggered();
                        }
                    }
                ]
            }
        ]
        
        onSearchModeChanged: {
            if (main.searchMode) {
                main.titleBar = inputTitleBar;
                main.titleBar.focus();
            } else {
                main.titleBar.reset();
                main.titleBar = titleBar;
                navigation.renderTree(_tasksService.findAll());
            }
        }
        
        attachedObjects: [
            CustomTitleBar {
                id: titleBar
                title: qsTr("All Tasks") + Retranslate.onLocaleOrLanguageChanged
                clearable: _tasksService.activeTask !== null && _tasksService.activeTask !== undefined;
            },
            
            InputTitleBar {
                id: inputTitleBar
                
                onCancel: {
                    main.searchMode = false;
                }
                
                onTyping: {
                    var filteredTasks = main.tasks.filter(function(t) {
                        return t.name.toLowerCase().startsWith(text.toLowerCase());
                    });
                    deleteAllTasks();
                    filteredTasks.forEach(function(t) {
                        tasksContainer.add(createSingleTaskComponent(t));
                    });
                }
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
                        if (_tasksService.multiselectMode) {
                            _tasksService.moveBulk(chosenTask.id);
                        } else {
                            if (_tasksService.activeTask.parentId !== chosenTask.id) {
                                _tasksService.moveTask(chosenTask.id);
                            }
                        }
                        navigation.pop();
                    }
                }
            },
            
            ComponentDefinition {
                id: contacts
                ContactsPage {
                    id: contactsPage
                    onTasksSent: {
                        contactsPage.clear();
                        navigation.pop();
                    }
                }    
            },
            
            ComponentDefinition {
                id: taskViewPage
                TaskViewPage {}    
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
            
            SystemToast {
                id: toast
            },
            
            SystemDialog {
                id: deleteTaskDialog
                
                title: qsTr("Confirm the deleting") + Retranslate.onLocaleOrLanguageChanged
                body: qsTr("This action cannot be undone. Also, task may contain children. All these will be deleted. Continue?") + Retranslate.onLocaleOrLanguageChanged
                
                includeRememberMe: true
                rememberMeText: qsTr("Don't ask again") + Retranslate.onLocaleOrLanguageChanged
                rememberMeChecked: {
                    var dontAsk = _appConfig.get("do_not_ask_before_deleting");
                    return dontAsk !== "" && dontAsk === "true";
                }
                
                onFinished: {
                    if (value === 2) {
                        _appConfig.set("do_not_ask_before_deleting", deleteTaskDialog.rememberMeSelection() + "");
                        if (_tasksService.multiselectMode) {
                            var ids = _tasksService.deleteBulk();
                            ids.forEach(function(id) {
                                    deleteTask(id, tasksContainer);
                            });
                        } else {
                            var id = _tasksService.activeTask.id;
                            _tasksService.deleteTask(id);
                            deleteTask(id, tasksContainer);
                        }
                    }
                }
            },
            
            SystemListDialog {
                id: sortingDialog
                
                title: qsTr("Sort by") + Retranslate.onLocaleOrLanguageChanged + ": "
                autoUpdateEnabled: true
                
                includeRememberMe: true
                rememberMeText: qsTr("Descending order") + Retranslate.onLocaleOrLanguageChanged
                rememberMeChecked: main.isDescOrder();
                
                onFinished: {
                    if (value === 2) {
                        var i = sortingDialog.selectedIndices[0];
                        switch (i) {
                            case 0: _appConfig.set("sort_by", "id"); break;
                            case 1: _appConfig.set("sort_by", "name"); break;
                            case 2: _appConfig.set("sort_by", "deadline"); break;
                        }
                        
                        var descOrder = sortingDialog.rememberMeSelection();
                        _appConfig.set("desc_order", descOrder + "");
                        
                        navigation.renderTree();
                        sortingDialog.rememberMeChecked = main.isDescOrder();
                        main.renderSortingItems();
                    }
                }                
            },
            
            ComponentDefinition {
                id: debugPage
                DebugPage {}
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
        
        function changeMultiselectMode(multiselectMode) {
            main.multiselectMode = multiselectMode;
        }
        
        function renderSortingItems() {
            var sortBy = _appConfig.get("sort_by");
            sortingDialog.clearList();
            sortingDialog.appendItem(qsTr("Creation") + Retranslate.onLocaleOrLanguageChanged, true, sortBy === "id");
            sortingDialog.appendItem(qsTr("Name") + Retranslate.onLocaleOrLanguageChanged, true, sortBy === "name");
            sortingDialog.appendItem(qsTr("Deadline") + Retranslate.onLocaleOrLanguageChanged, true, sortBy === "deadline");
        }
        
        function isDescOrder() {
            var descOrder = _appConfig.get("desc_order");
            if (descOrder !== "" && descOrder === "true") {
                return true;
            }
            return false;
        }
        
        onCreationCompleted: {
            if (!_hasSharedFilesPermission) {
                permissionDialog.show();
            }
            _tasksService.activeTaskChanged.connect(main.updateTitleBar);
            _tasksService.viewModeChanged.connect(main.changeViewMode);
            _tasksService.multiselectModeChanged.connect(main.changeMultiselectMode);
            
            main.renderSortingItems();
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
            if (parent.clear) {
                parent.clear();
            }
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
            var control = tasksContainer.controls[tasksContainer.controls.length - 1];
            tasksContainer.remove(control);
            if (control.clear) {
                control.clear();
            }
            control.destroy();
        }
    }
    
    function createSingleTaskComponent(t, parent) {
        var newTask = taskComponent.createObject(parent !== undefined ? parent : this);
        newTask.name = t.name;
        newTask.type = t.type;
        newTask.taskId = t.id;
        newTask.expandable = (t.children && t.children.length !== 0) || t.type === "FOLDER" || t.type === "LIST";
        newTask.expanded = t.expanded;
        newTask.closed = t.closed;
        newTask.important = t.important;
        newTask.deadline = t.deadline;
        newTask.rememberId = t.remember_id;
        newTask.calendarId = parseInt(t.calendar_id);
        newTask.parentId = t.parent_id;
        newTask.color = t.color;
        newTask.taskViewRequested.connect(function() {
            viewActionItem.triggered();
        });
        return newTask;
    }
    
    function addTask(parent, t) {
        var newTask = createSingleTaskComponent(t, parent);
        
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
    
    function renderTree(tasksToRender) {
        loading.start();
        deleteAllTasks();
        
        var allTasks = tasksToRender;
        if (typeof tasksToRender !== 'object') {
            allTasks = undefined;
            tasksToRender = undefined;
        }
        if (!tasksToRender) {
            allTasks = _tasksService.findAll();
            main.tasks = allTasks;
        }
        
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
        loading.stop();
        
//        var dp = debugPage.createObject();
//        navigation.push(dp);
    }
    
    function openTaskSheetEditMode(data) {
        if (!data) {
            taskSheet.mode = taskSheet.modes.UPDATE;
        } else {
            taskSheet.data = data;
        }
        taskSheet.open();
    }
    
    onCreationCompleted: {
        if (!String.prototype.startsWith) {
            String.prototype.startsWith = function(searchString, position){
                position = position || 0;
                return this.substr(position, searchString.length) === searchString;
            };
        }
        renderTree();
        _tasksService.taskCreated.connect(navigation.onTaskCreated);
        _tasksService.quickFolderCreated.connect(navigation.onTaskCreated);
        _tasksService.taskMoved.connect(navigation.renderTree);
        _tasksService.taskMovedInBulk.connect(navigation.renderTree);
        _tasksService.parentIdChangedInDebug.connect(navigation.renderTree);
        _app.taskSheetRequested.connect(navigation.openTaskSheetEditMode);
        _app.tasksReceived.connect(navigation.renderTree);
        _app.taskCardDone.connect(navigation.renderTree);
        _app.taskCreatedFromExternal.connect(navigation.renderTree);
    }
}
