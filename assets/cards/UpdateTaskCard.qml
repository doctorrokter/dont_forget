import bb.cascades 1.4
import bb.system 1.2
import "../components"
import "../pages"

NavigationPane {
    id: navigation
    
    backButtonsVisible: false
    peekEnabled: true
    
    function quit() {
        _app.cardDone("Card done!");
    }
    
    Page {
        id: root
        
        titleBar: CustomTitleBar {
            title: qsTr("Update task") + Retranslate.onLocaleOrLanguageChanged;
            
            cancelAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    navigation.quit();
                }
            }
            
            submitAction: ActionItem {
                id: createTaskAction
                title: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
                enabled: true
                
                onTriggered: {
                    createTaskAction.enabled = false;
                    
                    var files = [];
                    var deadline = deadLineToggleButton.checked ? new Date(deadLineContainer.result).getTime() / 1000 : 0;
                    var important = importantToggleButton.checked ? 1 : 0;
                    var createInRemember = rememberToggleButton.checked ? 1 : 0;
                    var createInCalendar = deadLineToggleButton.checked && calendarToggleButton.checked ? 1 : 0;
                    
                    taskName.validate();
                    if (taskName.isValid()) {
                        _tasksService.createTask(taskName.result.trim(), description.result.trim(), "TASK", deadline, important, createInRemember, files, createInCalendar);
                        toast.show();
                    }
                }
            }
        }
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Overlay
        
        ScrollView {
            scrollRole: ScrollRole.Main
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                
                TaskNameContainer { 
                    id: taskName
                    value: _tasksService.activeTask.name
                }
                
                TaskDescriptionContainer { 
                    id: description 
                    value: _tasksService.activeTask.description 
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    Container {
                        horizontalAlignment: HorizontalAlignment.Fill
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(3)
                        rightPadding: ui.du(2.5)
                        bottomPadding: ui.du(2.0)
                        
                        layout: DockLayout {}
                        
                        Container {
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Left
                            Label {
                                text: qsTr("Close task") + Retranslate.onLocaleOrLanguageChanged
                            }
                        }
                        
                        Container {
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Right
                            CheckBox {
                                checked: _tasksService.activeTask.closed === 1
                            }
                        }
                    }    
                    Divider {}                
                }
                                
                ToggleBlock {
                    id: deadLineToggleButton
                    title: qsTr("Deadline") + Retranslate.onLocaleOrLanguageChanged
                    checked: _tasksService.activeTask.deadline !== 0
                }
                
                TaskDeadlineContainer {
                    id: deadLineContainer
                    visible: deadLineToggleButton.checked
                    date: new Date(_tasksService.activeTask.deadline * 1000)
                }
                
                ToggleBlock {
                    id: calendarToggleButton
                    title: qsTr("Add to Calendar") + Retranslate.onLocaleOrLanguageChanged
                    visible: deadLineToggleButton.checked
                }
                
                ToggleBlock {
                    id: rememberToggleButton
                    title: qsTr("Create in Remember") + Retranslate.onLocaleOrLanguageChanged
                    checked: _tasksService.activeTask.remember_id !== ""
                }
                
                ToggleBlock {
                    id: importantToggleButton
                    title: qsTr("Important") + Retranslate.onLocaleOrLanguageChanged
                    checked: _tasksService.activeTask.important === 1
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    leftPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    
                    Button {
                        horizontalAlignment: HorizontalAlignment.Fill
                        text: qsTr("Delete task") + Retranslate.onLocaleOrLanguageChanged
                        
                        onClicked: {
                            var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
                            if (doNotAsk && doNotAsk === "true") {
                                var id = _tasksService.activeTask.id;
                                _tasksService.deleteTask(id);
                                deleteTask(id, tasksContainer);
                            } else {
                                deleteTaskDialog.open();
                            }
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    minHeight: ui.du(20)
                }
            }
        }
        
        attachedObjects: [
            SystemToast {
                id: toast
                body: qsTr("Task updated!") + Retranslate.onLocaleOrLanguageChanged
                
                onFinished: {
                    navigation.quit();
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
        
        actions: [
            ActionItem {
                id: okAction
                title: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
                ActionBar.placement: ActionBarPlacement.Signature
                imageSource: "asset:///images/ic_done.png"
                enabled: createTaskAction.enabled
                
                onTriggered: {
                    createTaskAction.triggered();
                    createTaskAction.enabled = false;
                }
            }
        ]
    }
}
