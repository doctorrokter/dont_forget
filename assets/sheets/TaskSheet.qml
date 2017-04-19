import bb.cascades 1.4
import "../components"

Sheet {
    id: taskSheet
    
    property string data: ""
    property string mode: "CREATE"
    property variant modes: {
        CREATE: "CREATE",
        UPDATE: "UPDATE"
    }
    
    Page {
        id: page
        
        titleBar: CustomTitleBar {
            title: {
                if (taskSheet.mode === taskSheet.modes.CREATE) {
                    return qsTr("Create task") + Retranslate.onLocaleOrLanguageChanged;    
                }
                qsTr("Update task") + Retranslate.onLocaleOrLanguageChanged;
            }
            
            cancelAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    taskSheet.close();    
                }
            }
            
            submitAction: ActionItem {
                id: createTaskAction
                title: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
                enabled: true
                
                onTriggered: {
                    createTaskAction = false;
                    
                    var deadline = deadLineToggleButton.checked ? new Date(deadLineContainer.result).getTime() / 1000 : 0;
                    var important = importantToggleButton.checked ? 1 : 0;
                    var createInRemember = rememberToggleButton.checked ? 1 : 0;
                    var closed = closeTaskCheckbox.checked ? 1 : 0;
                    var createInCalendar = deadLineToggleButton.checked && calendarToggleButton.checked ? 1 : 0;
                    var color = palette.visible ? palette.color : "";
                    
                    var files = [];
                    for (var i = 0; i < attachmentsContainer.attachments.length; i++) {
                        files.push(attachmentsContainer.attachments[i]);
                    }
                    
                    taskName.validate();
                    if (taskName.isValid()) {
                        if (taskSheet.mode === taskSheet.modes.CREATE) {
                            var names = taskName.result.split(";;");
                            names.forEach(function(name) {
                                    _tasksService.createTask(name.trim(), description.result.trim(), taskType.selectedValue, deadline, important, createInRemember, files, createInCalendar, color);
                            });
                        } else {
                            _tasksService.updateTask(taskName.result.trim(), description.result.trim(), taskType.selectedValue, deadline, important, createInRemember, closed, files, createInCalendar, color);
                        }
                        taskSheet.close();
                    }
                }
            }
        }
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Overlay
        
        Container {
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
                    }
                    
                    AttachmentsContainer {
                        id: attachmentsContainer
                    }
                    
                    Container {
                        visible: taskSheet.mode === taskSheet.modes.UPDATE
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(2.5)
                        rightPadding: ui.du(2.5)
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        layout: DockLayout {}
                        
                        Label {
                            horizontalAlignment: HorizontalAlignment.Left
                            text: qsTr("Task done") + Retranslate.onLocaleOrLanguageChanged
                        }
                        
                        CheckBox {
                            id: closeTaskCheckbox
                            checked: false
                            horizontalAlignment: HorizontalAlignment.Right
                        }
                    }
                    
                    Container {
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(2.5)
                        rightPadding: ui.du(2.5)
                        DropDown {
                            id: taskType
                            
                            title: qsTr("Type") + Retranslate.onLocaleOrLanguageChanged
                            
                            options: [
                                Option {
                                    id: folderOption
                                    text: qsTr("Folder") + Retranslate.onLocaleOrLanguageChanged
                                    value: "FOLDER"
                                    
                                    onSelectedChanged: {
                                        if (selected) {
                                            palette.color = palette.colors.BLUE;
                                        }
                                    }
                                },
                                
                                Option {
                                    id: listOption
                                    text: qsTr("List") + Retranslate.onLocaleOrLanguageChanged
                                    value: "LIST"
                                    
                                    onSelectedChanged: {
                                        if (selected) {
                                            palette.color = palette.colors.GREEN;
                                        }
                                    }
                                },
                                
                                Option {
                                    id: taskOption
                                    text: qsTr("Task") + Retranslate.onLocaleOrLanguageChanged
                                    value: "TASK"
                                }
                            ]
                        }
                    }
                    
                    Palette {
                        id: palette
                        
                        horizontalAlignment: HorizontalAlignment.Center
                        visible: folderOption.selected || listOption.selected
                        
                        color: palette.colors.BLUE;
                        
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(2.5)
                        rightPadding: ui.du(2.5)
                    }
                    
                    ToggleBlock {
                        id: deadLineToggleButton
                        title: qsTr("Deadline") + Retranslate.onLocaleOrLanguageChanged
                    }
                    
                    TaskDeadlineContainer {
                        id: deadLineContainer
                        visible: deadLineToggleButton.checked
                        date: currDatePlus2Hourse();
                    }
                    
                    ToggleBlock {
                        id: calendarToggleButton
                        title: qsTr("Add to Calendar") + Retranslate.onLocaleOrLanguageChanged
                        visible: deadLineToggleButton.checked
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
        }
        
        shortcuts: [
            DeviceShortcut {
                type: DeviceShortcuts.BackTap
                
                onTriggered: {
                    taskSheet.close();
                }
            }
        ]
        
        actions: [
            ActionItem {
                id: attach
                title: qsTr("Attachment") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_attach.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    filePickersSheet.open();
                }
            },
            
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
        
        attachedObjects: [
            FilePickersSheet {
                id: filePickersSheet
                
                onAttachmentsChosen: {
                    var newAttachments = attachmentsContainer.attachments.concat(attachments);
                    attachmentsContainer.attachments = newAttachments;
                }
            }
        ]
    }
    
    function adjustCreateInRemember() {
        if (taskSheet.mode === taskSheet.modes.CREATE) {
            var remember = _appConfig.get("auto_create_in_remember");
            rememberToggleButton.checked = remember && remember === "true";
        } else {
            rememberToggleButton.checked = _tasksService.activeTask.rememberId !== "";
        }
    }
    
    function adjustCreateInCalendar() {
        if (taskSheet.mode === taskSheet.modes.CREATE) {
            calendarToggleButton.checked = false;
        } else {
            var c = _tasksService.activeTask.calendarId;
            calendarToggleButton.checked = _tasksService.activeTask.calendarId !== 0;
        }
    }
    
    function adjustDeadline() {
        if (taskSheet.mode === taskSheet.modes.CREATE) {
            deadLineContainer.date = currDatePlus2Hourse();
        } else {
           if (_tasksService.activeTask.deadline !== 0) {
               deadLineContainer.date = new Date(_tasksService.activeTask.deadline * 1000);
           } else {
               deadLineContainer.date = currDatePlus2Hourse();
           }
        }
    }
    
    function adjustFolderOption() {
        var defaultTaskType = _appConfig.get("default_task_type");
        folderOption.selected = defaultTaskType === folderOption.value;
    }
    
    function adjustTaskOption() {
        var defaultTaskType = _appConfig.get("default_task_type");
        taskOption.selected = defaultTaskType === "" || defaultTaskType === taskOption.value;
    }
    
    function adjustAttachments() {
        if (taskSheet.mode === taskSheet.modes.CREATE) {
            attachmentsContainer.attachments = [];
        } else {
            attachmentsContainer.attachments = _attachmentsService.findByTaskId(_tasksService.activeTask.id);
        }
    }
    
    function currDatePlus2Hourse() {
        return new Date(new Date().getTime() + 7200000);
    }
    
    function initialState() {
        if (!taskSheet.data) {
            taskName.resetText();
        }
        importantToggleButton.checked = false;
        deadLineToggleButton.checked = false;
        calendarToggleButton.checked = false;
        deadLineContainer.date = currDatePlus2Hourse();
        description.resetText();
        adjustFolderOption();
        adjustTaskOption();
        adjustCreateInRemember();
        adjustCreateInCalendar();
        adjustAttachments();
    }
    
    function adjustClosedTask() {
        closeTaskCheckbox.checked = _tasksService.activeTask !== null && _tasksService.activeTask.closed;
    }
    
    onOpened: {
        createTaskAction.enabled = true;
        if (taskSheet.mode === taskSheet.modes.UPDATE) {
            importantToggleButton.checked = _tasksService.activeTask.important;
            deadLineToggleButton.checked = _tasksService.activeTask.deadline !== 0;
            folderOption.selected = _tasksService.activeTask.type === folderOption.value;
            taskOption.selected = _tasksService.activeTask.type === taskOption.value;
            listOption.selected = _tasksService.activeTask.type === listOption.value;
            taskName.value = _tasksService.activeTask.name;
            description.value = _tasksService.activeTask.description;
        } else {
            initialState();
        }
        adjustCreateInRemember();
        adjustCreateInCalendar();
        adjustDeadline();
        adjustClosedTask();
        adjustAttachments();
        taskName.requestFocus();
    }
    
    onClosed: {
        taskSheet.data = "";
        taskSheet.mode = taskSheet.modes.CREATE;
        closeTaskCheckbox.checked = false;
        initialState();
    }
    
    onDataChanged: {
        taskName.value = taskSheet.data;
    }
}