import bb.cascades 1.4
import bb.system 1.2
import "../components"
import "../pages"
import "../js/Const.js" as Const

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
            title: qsTr("Create task") + Retranslate.onLocaleOrLanguageChanged;
            
            cancelAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    navigation.quit();
                }
            }
        }
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Overlay
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            layout: DockLayout {}
            
            ScrollView {
                scrollRole: ScrollRole.Main
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    TaskNameContainer { 
                        id: taskName 
                    }
                    
                    TaskDescriptionContainer {
                        id: description
                        margin.topOffset: ui.du(2)
                    }
                    
                    AttachmentsContainer {
                        id: attachmentsContainer
                    }
                    
                    ToggleBlock {
                        id: deadLineToggleButton
                        title: qsTr("Deadline") + Retranslate.onLocaleOrLanguageChanged
                    }
                    
                    TaskDeadlineContainer {
                        id: deadLineContainer
                        visible: deadLineToggleButton.checked
                        date: root.currDatePlus2Hourse();
                    }
                    
                    ToggleBlock {
                        id: calendarToggleButton
                        title: qsTr("Add to Calendar") + Retranslate.onLocaleOrLanguageChanged
                        visible: deadLineToggleButton.checked
                    }
                    
                    Container {
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(2.5)
                        rightPadding: ui.du(2.5)
                        visible: calendarToggleButton.checked
                        DropDown {
                            id: calendarAccounts
                            title: qsTr("Account") + Retranslate.onLocaleOrLanguageChanged
                        }
                    }
                    
                    ToggleBlock {
                        id: rememberToggleButton
                        title: qsTr("Create in Remember") + Retranslate.onLocaleOrLanguageChanged
                    }
                    
                    ToggleBlock {
                        id: importantToggleButton
                        title: qsTr("Important") + Retranslate.onLocaleOrLanguageChanged
                    }
                    
                    Container {
                        horizontalAlignment: HorizontalAlignment.Fill
                        preferredHeight: ui.du(12)
                    }
                }
            }
            
            ActivityIndicator {
                id: spinner
                running: false
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                minWidth: ui.du(10)
            }
        }
        
        actions: [
            ActionItem {
                id: okAction
                title: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
                ActionBar.placement: ActionBarPlacement.Signature
                imageSource: "asset:///images/ic_done.png"
                enabled: createTaskAction.enabled
                
                onTriggered: {
                    if (!spinner.running) {
                        var files = [];
                        for (var i = 0; i < attachmentsContainer.attachments.length; i++) {
                            files.push(attachmentsContainer.attachments[i]);
                        }
                        
                        var deadline = deadLineToggleButton.checked ? new Date(deadLineContainer.result).getTime() / 1000 : 0;
                        var important = importantToggleButton.checked ? 1 : 0;
                        var createInRemember = rememberToggleButton.checked ? 1 : 0;
                        var createInCalendar = deadLineToggleButton.checked && calendarToggleButton.checked ? 1 : 0;
                        
                        var folderId = 1;
                        var accountId = 1;
                        if (createInCalendar === 1) {
                            folderId = calendarAccounts.selectedValue.folderId;
                            accountId = calendarAccounts.selectedValue.accountId;
                        }
                        
                        taskName.validate();
                        if (taskName.isValid()) {
                            spinner.start();
                            _tasksService.createTask(taskName.result.trim(), Const.TaskTypes.TASK);
                            var newTask = _tasksService.lastCreated();
                            _tasksService.setActiveTask(newTask.id);
                            _tasksService.updateTask(newTask.name, description.result.trim(), deadline, important, createInRemember, files, createInCalendar, folderId, accountId);
                            _tasksService.flushActiveTask();
                        }
                    }
                }
            }
        ]
        
        function setTitle(title) {
            taskName.value = title;
        }
        
        function currDatePlus2Hourse() {
            return new Date(new Date().getTime() + 7200000);
        }
        
        function processAttachments() {
            taskName.requestFocus();
            
            var parts = _data.split("/");
            var name = parts[parts.length - 1];
            var file = {name: name, mime_type: _mimeType, path: _data};
            attachmentsContainer.attachments = [file];
        }
        
        onCreationCompleted: {
            if (!_mimeType || _mimeType.trim() === "") {
                description.value = _data;
                
                var xhr = new XMLHttpRequest();
                xhr.open("GET", _data, true);
                xhr.onreadystatechange = function () {
                    if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                        var title = /<title>(.*?)<\/title>/g.exec(xhr.responseText);
                        root.setTitle(title[1] || "");
                    }
                };
                xhr.send();
                
            } else {
                processAttachments();
            }
            _tasksService.taskUpdated.connect(toast.show);
        }
        
        attachedObjects: [
            SystemToast {
                id: toast
                body: qsTr("Task created!") + Retranslate.onLocaleOrLanguageChanged
                
                onFinished: {
                    _app.createFromExternal();
                    navigation.quit();
                }
            }
        ]
    }
    
    onCreationCompleted: {
        _calendar.initFolders(calendarAccounts);
    }
}
