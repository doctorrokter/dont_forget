import bb.cascades 1.4
import bb.system 1.2
import "./components"
import "./components/v2"
import "./pages"
import "./js/Const.js" as Const
import "./js/assign.js" as Assign

TabbedPane {
    id: tabbedPane
    
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
    
    activePane: NavigationPane {
        
        id: navigationPane
        
        Page {
            id: root
            
            titleBar: defaultTitleBar
            
            actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
            actionBarVisibility: ChromeVisibility.Overlay
            
            BackgroundContainer {
                MoverContainer {
                    UnsortedListView {
                        id: listView
                        
                        taskId: 0
                        scrollRole: ScrollRole.Main
                        
                        onReload: {
                            root.reload();
                        }
                        
                        onOpenFolder: {
                            var fp = folderPage.createObject();
                            fp.name = name;
                            fp.path = "/" + name;
                            fp.taskId = taskId;
                            navigationPane.push(fp);
                        }
                        
                        onOpenList: {
                            var lp = listPage.createObject();
                            lp.name = name;
                            lp.path = "/" + name;
                            lp.taskId = taskId;
                            navigationPane.push(lp);
                        }
                        
                        onOpenTask: {
                            navigationPane.openTask(taskId);
                        }
                        
                        onOpenContactsPage: {
                            navigationPane.openContactsPage();
                        }
                    }
                }
            }
            
            function taskUpdated(activeTask, parentId) {
                navigationPane.pop();
                recount();
            }
            
            function taskClosedChanged(taskId, closed, parentId) {
                recount();
            }
            
            function taskDeleted(taskId, parentId, parentParentId) {
                recount();
            }
            
            function recount() {
                root.updateTab(todayTab, _tasksService.countTodayTasks());
                root.updateTab(importantTab, _tasksService.countImportantTasks());
                root.updateTab(overdueTab, _tasksService.countOverdueTasks());
                root.updateTab(completedTab, _tasksService.countCompletedTasks());
                root.updateTab(upcomingTab, _tasksService.countUpcomingTasks());
                root.updateTab(receivedTab, _tasksService.countReceivedTasks());
            }
            
            function updateTab(tab, count) {
                tab.unreadContentCount = count;
            }
            
            function reload() {
                root.recount();
                root.refresh();
            }
            
            function refresh() {
                listView.flush();
                listView.append(_tasksService.findSiblings());
            }
            
            function tasksMovedInBulk(parentId) {
                root.reload();
            }
            
            function onThumbnail() {
                highCover.update();
                Application.setCover(cover);
            }
            
            function isDescOrder() {
                var descOrder = _appConfig.get("desc_order");
                if (descOrder !== "" && descOrder === "true") {
                    return true;
                }
                return false;
            }
            
            function renderSortingItems() {
                var sortBy = _appConfig.get("sort_by");
                sortingDialog.clearList();
                sortingDialog.appendItem(qsTr("Creation") + Retranslate.onLocaleOrLanguageChanged, true, sortBy === "id");
                sortingDialog.appendItem(qsTr("Name") + Retranslate.onLocaleOrLanguageChanged, true, sortBy === "name");
                sortingDialog.appendItem(qsTr("Deadline") + Retranslate.onLocaleOrLanguageChanged, true, sortBy === "deadline");
            }
            
            onCreationCompleted: {
                root.reload();
                root.renderSortingItems();
                
                _tasksService.taskUpdated.connect(root.taskUpdated);
                _tasksService.taskClosedChanged.connect(root.taskClosedChanged);
                _tasksService.taskDeleted.connect(root.taskDeleted);
                _tasksService.taskMovedInBulk.connect(root.tasksMovedInBulk);
                _app.tasksReceived.connect(root.reload);
                Application.thumbnail.connect(root.onThumbnail);
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
                    id: openSortingDialog
                    
                    title: qsTr("Sort") + Retranslate.onLocaleOrLanguageChanged
                    imageSource: "asset:///images/ic_sort.png"
                    
                    onTriggered: {
                        sortingDialog.show();
                    }
                    
                    shortcuts: [
                        Shortcut {
                            key: "s"
                            
                            onTriggered: {
                                openSortingDialog.triggered();
                            }
                        }
                    ]
                }
                
                
                
                //            ActionItem {
                //                id: chartsActionItem
                //                imageSource: "asset:///images/ic_chart.png"
                //                title: qsTr("Charts") + Retranslate.onLocaleOrLanguageChanged
                //                
                //                onTriggered: {
                //                    var cp = chartsPage.createObject();
                //                    navigationPane.push(cp);
                //                }
                //            }
                
                //            ActionItem {
                //                id: debugActionItem
                //                title: "Debug"
                //                
                //                onTriggered: {
                //                    var dp = debugPage.createObject();
                //                    navigationPane.push(dp);
                //                }
                //            }
            ]
        }
        
        attachedObjects: [
            SystemListDialog {
                id: sortingDialog
                
                title: qsTr("Sort by") + Retranslate.onLocaleOrLanguageChanged + ": "
                autoUpdateEnabled: true
                
                includeRememberMe: true
                rememberMeText: qsTr("Descending order") + Retranslate.onLocaleOrLanguageChanged
                rememberMeChecked: root.isDescOrder();
                
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
                        
                        root.refresh();
                        sortingDialog.rememberMeChecked = root.isDescOrder();
                        root.renderSortingItems();
                    }
                }                
            },
            
            SceneCover {
                id: cover
                
                content: HighCover {
                    id: highCover
                }    
            },
            
            ComponentDefinition {
                id: backgroundPage
                BackgroundPage {
                    onImageChanged: {
                        navigationPane.pop();
                    }
                }    
            },
            
            ComponentDefinition {
                id: settingsPage
                SettingsPage {
                    onBackgroundPageRequested: {
                        var bg = backgroundPage.createObject();
                        navigationPane.push(bg);
                    }
                }
            },
            
            ComponentDefinition {
                id: helpPage
                HelpPage {}
            },
            
            ComponentDefinition {
                id: folderPage
                FolderPage {
                    onOpenFolder: {
                        navigationPane.openFolder(taskId, path);
                    }
                    
                    onOpenList: {
                        navigationPane.openList(taskId, path);
                    }
                    
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }    
            },
            
            ComponentDefinition {
                id: listPage
                ListPage {
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }    
            },
            
            ComponentDefinition {
                id: importantPage
                ImportantPage {
                    onOpenFolder: {
                        navigationPane.openFolder(taskId, "");
                    }
                    
                    onOpenList: {
                        navigationPane.openList(taskId, "");
                    }
                    
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }   
            },
            
            ComponentDefinition {
                id: todayPage
                TodayPage {
                    onOpenFolder: {
                        navigationPane.openFolder(taskId, "");
                    }
                    
                    onOpenList: {
                        navigationPane.openList(taskId, "");
                    }
                    
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }    
            },
            
            ComponentDefinition {
                id: overduePage
                OverduePage {
                    onOpenFolder: {
                        navigationPane.openFolder(taskId, "");
                    }
                    
                    onOpenList: {
                        navigationPane.openList(taskId, "");
                    }
                    
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }    
            },
            
            ComponentDefinition {
                id: completedPage
                CompletedPage {
                    onOpenFolder: {
                        navigationPane.openFolder(taskId, "");
                    }
                    
                    onOpenList: {
                        navigationPane.openList(taskId, "");
                    }
                    
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }
            },
            
            ComponentDefinition {
                id: upcomingPage
                UpcomingPage {
                    onOpenFolder: {
                        navigationPane.openFolder(taskId, "");
                    }
                    
                    onOpenList: {
                        navigationPane.openList(taskId, "");
                    }
                    
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }
            },
            
            ComponentDefinition {
                id: receivedPage
                ReceivedPage {
                    onOpenFolder: {
                        navigationPane.openFolder(taskId, "");
                    }
                    
                    onOpenList: {
                        navigationPane.openList(taskId, "");
                    }
                    
                    onOpenTask: {
                        navigationPane.openTask(taskId);
                    }
                    
                    onOpenContactsPage: {
                        navigationPane.openContactsPage();
                    }
                }
            },
            
            ComponentDefinition {
                id: contactsPage
                ContactsPage {}    
            },
            
            ComponentDefinition {
                id: taskPage
                TaskPage {}    
            },
            
            ComponentDefinition {
                id: chartsPage
                ChartsPage {}    
            },
            
            ComponentDefinition {
                id: debugPage
                DebugPage {}    
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
                title: qsTr("Root") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_home.png"
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
        
        function openFolder(taskId, path) {
            var fp = folderPage.createObject();
            var folder = _tasksService.findById(taskId);
            fp.path = path + "/" + folder.name;
            fp.name = folder.name;
            fp.taskId = taskId;
            navigationPane.push(fp);
        }
        
        function openList(taskId, path) {
            var list = _tasksService.findById(taskId);
            var lp = listPage.createObject();
            lp.name = list.name;
            lp.path = path + "/" + list.name;
            lp.taskId = taskId;
            navigationPane.push(lp);
        }
        
        function openTask(taskId) {
            _tasksService.setActiveTask(taskId);
            var tp = taskPage.createObject();
            navigationPane.push(tp);
        }
        
        function openContactsPage() {
            var cp = contactsPage.createObject();
            navigationPane.push(cp);
        }
        
        onPopTransitionEnded: {
            Application.menuEnabled = true;
            if (page.clear) {
                page.clear();
            }
            page.destroy();
            if (tabbedPane.activePane.count() === 1) {
                tabbedPane.activeTab = mainTab;
            }
        }
    }
    
    Tab {
        id: mainTab
        
        title: qsTr("Root") + Retranslate.onLocaleOrLanguageChanged
        imageSource: "asset:///images/ic_home.png"
    }
    
    Tab {
        id: receivedTab
        imageSource: "asset:///images/ic_inbox.png"
        title: qsTr("Received") + Retranslate.onLocaleOrLanguageChanged
        unreadContentCount: 0
        
        onTriggered: {
            newContentAvailable = false;
            var rp = receivedPage.createObject();
            tabbedPane.activePane.push(rp);
        }
    }
    
    Tab {
        id: todayTab
        imageSource: "asset:///images/ic_calendar.png"
        title: qsTr("Today") + Retranslate.onLocaleOrLanguageChanged
        unreadContentCount: 0
        
        onTriggered: {
            newContentAvailable = false;
            var tp = todayPage.createObject();
            tabbedPane.activePane.push(tp);
        }
    }
    
    Tab {
        id: upcomingTab
        imageSource: "asset:///images/ic_reload.png"
        title: qsTr("Upcoming") + Retranslate.onLocaleOrLanguageChanged
        unreadContentCount: 0
        
        onTriggered: {
            newContentAvailable = false;
            var up = upcomingPage.createObject();
            tabbedPane.activePane.push(up);
        }
    }
    
    Tab {
        id: importantTab
        imageSource: "asset:///images/ic_important.png"
        title: qsTr("Important") + Retranslate.onLocaleOrLanguageChanged
        unreadContentCount: 0
        
        onTriggered: {
            newContentAvailable = false;
            var ip = importantPage.createObject();
            tabbedPane.activePane.push(ip);
        }
    }
    
    Tab {
        id: overdueTab
        imageSource: "asset:///images/ic_history.png"
        title: qsTr("Overdue") + Retranslate.onLocaleOrLanguageChanged
        unreadContentCount: 0
        
        onTriggered: {
            newContentAvailable = false;
            var op = overduePage.createObject();
            tabbedPane.activePane.push(op);
        }
    }
    
    Tab {
        id: completedTab
        imageSource: "asset:///images/ic_done.png"
        title: qsTr("Completed") + Retranslate.onLocaleOrLanguageChanged
        unreadContentCount: 0
        
        onTriggered: {
            newContentAvailable = false;
            var cp = completedPage.createObject();
            tabbedPane.activePane.push(cp);
        }
    }
}
