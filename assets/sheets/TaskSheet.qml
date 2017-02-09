import bb.cascades 1.4
import "../components"

Sheet {
    id: taskSheet
    
    property string mode: "CREATE"
    property variant modes: {
        CREATE: "CREATE",
        UPDATE: "UPDATE"
    }
    
    Page {
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
                title: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    var deadline = deadLineToggleButton.checked ? new Date(deadlineDateTimePicker.value).getTime() / 1000 : 0;
                    var important = importantToggleButton.checked ? 1 : 0;
                    var createInRemember = rememberToggleButton.checked ? 1 : 0;
                    
                    if (taskSheet.mode === taskSheet.modes.CREATE) {
                        var names = taskName.text.split(";;");
                        names.forEach(function(name) {
                            _tasksService.createTask(name.trim(), description.text.trim(), taskType.selectedValue, deadline, important, createInRemember);
                        });
                    } else {
                        _tasksService.updateTask(taskName.text, description.text, taskType.selectedValue, deadline, important, createInRemember);
                    }
                    taskSheet.close();    
                }
            }
        }
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        actionBarVisibility: ChromeVisibility.Overlay
        
        ScrollView {
            scrollRole: ScrollRole.Main
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                Container {
                    Container {
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(2.5)
                        Label {
                            text: qsTr("Name") + Retranslate.onLocaleOrLanguageChanged
                        }
                    }
                    
                    TextField {
                        id: taskName
                        inputMode: TextFieldInputMode.Text
                    }
                }
                
                Container {
                    Container {
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(2.5)
                        Label {
                            text: qsTr("Description") + Retranslate.onLocaleOrLanguageChanged
                        }
                    }
                    
                    TextArea {
                        id: description
                        minHeight: ui.du(25)
                        autoSize.maxLineCount: 10
                        scrollMode: TextAreaScrollMode.Elastic
                        inputMode: TextAreaInputMode.Text
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
                            },
                            
                            Option {
                                id: taskOption
                                text: qsTr("Task") + Retranslate.onLocaleOrLanguageChanged
                                value: "TASK"
                            }
                        ]
                    }
                }
                
                
                ToggleBlock {
                    id: deadLineToggleButton
                    title: qsTr("Deadline") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    id: deadLineContainer
                    visible: deadLineToggleButton.checked
                    Container {
                        leftPadding: ui.du(2.5)
                        topPadding: ui.du(2.5)
                        rightPadding: ui.du(2.5)
                        
                        DateTimePicker {
                            id: deadlineDateTimePicker
                            title: qsTr("Date") + Retranslate.onLocaleOrLanguageChanged
                            mode: DateTimePickerMode.DateTime
                            value: currDatePlus2Hourse();
                        }
                    }
                    
                    Divider {}
                }
                
                ToggleBlock {
                    id: rememberToggleButton
                    title: qsTr("Create in Remember") + Retranslate.onLocaleOrLanguageChanged
                }
                
                ToggleBlock {
                    id: importantToggleButton
                    title: qsTr("Important") + Retranslate.onLocaleOrLanguageChanged
                }
            }
        }
    }
    
    function adjustCreateInRemember() {
        if (taskSheet.mode === taskSheet.modes.CREATE) {
            var remember = _appConfig.get("auto_create_in_remember");
            rememberToggleButton.checked = remember && remember === "true";
        } else {
            rememberToggleButton.checked = _tasksService.activeTask.rememberId !== "";
        }
    }
    
    function adjustDeadline() {
        if (taskSheet.mode === taskSheet.modes.CREATE) {
            deadlineDateTimePicker.value = currDatePlus2Hourse();
        } else {
           if (_tasksService.activeTask.deadline !== 0) {
               deadlineDateTimePicker.value = new Date(_tasksService.activeTask.deadline * 1000);
           } else {
               deadlineDateTimePicker.value = currDatePlus2Hourse();
           }
        }
    }
    
    function adjustFolderOption() {
        var defaultTaskType = _appConfig.get("default_task_type");
        folderOption.selected = defaultTaskType === "" || defaultTaskType === folderOption.value;
    }
    
    function adjustTaskOption() {
        var defaultTaskType = _appConfig.get("default_task_type");
        taskOption.selected = defaultTaskType === taskOption.value;
    }
    
    function currDatePlus2Hourse() {
        return new Date(new Date().getTime() + 7200000);
    }
    
    function initialState() {
        importantToggleButton.checked = false;
        deadLineToggleButton.checked = false;
        deadlineDateTimePicker.value = currDatePlus2Hourse();
        taskName.resetText();
        description.resetText();
        adjustFolderOption();
        adjustTaskOption();
    }
    
    onOpened: {
        if (taskSheet.mode === taskSheet.modes.UPDATE) {
            importantToggleButton.checked = _tasksService.activeTask.important;
            deadLineToggleButton.checked = _tasksService.activeTask.deadline !== 0;
            folderOption.selected = _tasksService.activeTask.type === folderOption.value;
            taskOption.selected = _tasksService.activeTask.type === taskOption.value;
            taskName.text = _tasksService.activeTask.name;
            description.text = _tasksService.activeTask.description;
        } else {
            initialState();
        }
        adjustCreateInRemember();
        adjustDeadline();
    }
    
    onClosed: {
        taskSheet.mode = taskSheet.modes.CREATE;
        initialState();
    }
}