import bb.cascades 1.4
import "../components"
import "../sheets"
import "../js/Const.js" as Const

Page {
    
    id: root
    
    titleBar: defaultTitleBar
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            ToggleBlock {
                id: deadLineToggleButton
                title: qsTr("Deadline") + Retranslate.onLocaleOrLanguageChanged
                checked: _tasksService.activeTask.deadline !== 0
            }
            
            TaskDeadlineContainer {
                id: deadLineContainer
                visible: deadLineToggleButton.checked
                date: root.getDeadline();
            }
            
            ToggleBlock {
                id: calendarToggleButton
                title: qsTr("Add to Calendar") + Retranslate.onLocaleOrLanguageChanged
                visible: deadLineToggleButton.checked
                checked: _tasksService.activeTask.calendarId !== 0
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
                title: qsTr("Add to Remember") + Retranslate.onLocaleOrLanguageChanged
                checked: _tasksService.activeTask.rememberId !== ""
            }
            
            ToggleBlock {
                id: importantToggleButton
                title: qsTr("Important") + Retranslate.onLocaleOrLanguageChanged
                checked: _tasksService.activeTask.important
                
                onCheckedChanged: {
                    if (checked !== _tasksService.activeTask.important) {
                        _tasksService.activeTask.important = checked;
                    }
                }
            }
            
            TaskDescriptionContainer {
                id: description
                visible: _tasksService.activeTask.type === Const.TaskTypes.TASK
                value: _tasksService.activeTask.description || ""
            }
            
            Palette {
                id: palette
                
                horizontalAlignment: HorizontalAlignment.Center
                visible: _tasksService.activeTask.type === Const.TaskTypes.LIST
                
                color: _tasksService.activeTask.color === "" ? palette.colors.GREEN : _tasksService.activeTask.color
                
                leftPadding: ui.du(2.5)
                topPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
            }
            
            AttachmentsContainer {
                id: attachmentsContainer
                attachments: _attachmentsService.findByTaskId(_tasksService.activeTask.id)
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                preferredHeight: ui.du(12)
            }
        }
    }
    
    function getDeadline() {
        if (_tasksService.activeTask.deadline !== 0) {
            return new Date(_tasksService.activeTask.deadline * 1000);
        }
        return currDatePlus2Hours();
    }
    
    function currDatePlus2Hours() {
        return new Date(new Date().getTime() + 7200000);
    }
    
    function adjustCalendarFolders() {
        calendarAccounts.removeAll();
        if (_tasksService.activeTask !== null) {
            _calendar.initFolders(calendarAccounts, _tasksService.activeTask.folderId, _tasksService.activeTask.accountId);
        } else {
            var accountId = _appConfig.get("default_account_id");
            var folderId = _appConfig.get("default_folder_id");
            if (accountId === "" || folderId === "") {
                accountId = 1;
                folderId = 1;
            }
            _calendar.initFolders(calendarAccounts, folderId, accountId);
        }
    }
    
    onCreationCompleted: {
        adjustCalendarFolders();
    }
    
    actions: [
        ActionItem {
            id: rename
            title: qsTr("Rename") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar    
            imageSource: "asset:///images/ic_rename.png"
            
            onTriggered: {
                root.titleBar = inputTitleBar;
                inputTitleBar.focus();
            }
            
            shortcuts: [
                Shortcut {
                    key: "r"
                    
                    onTriggered: {
                        rename.triggered();
                    }
                }
            ]
        },
        
        ActionItem {
            id: attach
            title: qsTr("Attachment") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_attach.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: _tasksService.activeTask.type === Const.TaskTypes.TASK
            
            onTriggered: {
                filePickersSheet.open();
            }
            
            shortcuts: [
                Shortcut {
                    key: "a"
                    
                    onTriggered: {
                        attach.triggered();
                    }
                }
            ]
        },
        
        ActionItem {
            id: okAction
            title: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "asset:///images/ic_done.png"
            
            onTriggered: {
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
                    
                    var files = [];
                    for (var i = 0; i < attachmentsContainer.attachments.length; i++) {
                        files.push(attachmentsContainer.attachments[i]);
                    }
                    
                    var taskName = _tasksService.activeTask.name;
                    _tasksService.updateTask(taskName.trim(), description.result.trim(), deadline, important, createInRemember, files, createInCalendar, folderId, accountId, palette.color);
            }
        }
    ]
    
    attachedObjects: [
        CustomTitleBar {
            id: defaultTitleBar
            title: _tasksService.activeTask.name
        },
        
        InputTitleBar {
            id: inputTitleBar
            
            onSubmit: {
                if (text.trim()) {
                    _tasksService.activeTask.name = text.trim();
                    reset();
                    root.titleBar = defaultTitleBar;
                }
            }
            
            onCancel: {
                reset();
                root.titleBar = defaultTitleBar;
            }
        },
        
        FilePickersSheet {
            id: filePickersSheet
            
            onAttachmentsChosen: {
                var newAttachments = attachmentsContainer.attachments.concat(attachments);
                attachmentsContainer.attachments = newAttachments;
            }
        }
    ]
}
