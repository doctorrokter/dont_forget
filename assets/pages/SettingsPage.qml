import bb.cascades 1.4
import "../components"

Page {
    id: root
    
    signal sortByChanged();
    signal defaultTaskTypeChanged();
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    titleBar: CustomTitleBar {
        title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged
    }
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Header {
                title: qsTr("Look and Feel") + Retranslate.onLocaleOrLanguageChanged
            }
            
            Container {
                layout: DockLayout {}
                topPadding: ui.du(2)
                bottomPadding: ui.du(2.5)
                leftPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    text: qsTr("Dark theme") + Retranslate.onLocaleOrLanguageChanged
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Left
                }
                
                ToggleButton {
                    id: themeToggle
                    horizontalAlignment: HorizontalAlignment.Right
                    
                    onCheckedChanged: {
                        if (checked) {
                            Application.themeSupport.setVisualStyle(VisualStyle.Dark);
                            _appConfig.set("theme", "DARK");
                        } else {
                            Application.themeSupport.setVisualStyle(VisualStyle.Bright);
                            _appConfig.set("theme", "BRIGHT");
                        }
                    }
                }
            }
            
            Header {
                title: qsTr("Behavior") + Retranslate.onLocaleOrLanguageChanged
            }
            
            Container {
                layout: DockLayout {}
                topPadding: ui.du(2)
                bottomPadding: ui.du(0.5)
                leftPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    text: qsTr("Don't ask before deleting") + Retranslate.onLocaleOrLanguageChanged
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Left
                }
                
                ToggleButton {
                    id: dontAskBeforeDeletingToggle
                    horizontalAlignment: HorizontalAlignment.Right
                    
                    onCheckedChanged: {
                        if (checked) {
                            _appConfig.set("do_not_ask_before_deleting", "true");
                        } else {
                            _appConfig.set("do_not_ask_before_deleting", "false");
                        }
                    }
                }
            }  
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: ui.du(2.5)
                leftPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
                DropDown {
                    title: qsTr("Sort by") + Retranslate.onLocaleOrLanguageChanged
                    
                    options: [
                        Option {
                            id: sortByNameOption
                            text: qsTr("Name") + Retranslate.onLocaleOrLanguageChanged
                            value: "name"
                        },
                        
                        Option {
                            id: sortByCreationOption
                            text: qsTr("Creation") + Retranslate.onLocaleOrLanguageChanged
                            value: "id"
                        }
                    ]
                    
                    onSelectedOptionChanged: {
                        _appConfig.set("sort_by", selectedOption.value);
                        root.sortByChanged();
                    }
                }
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: ui.du(2.5)
                leftPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
                DropDown {
                    title: qsTr("Default task type") + Retranslate.onLocaleOrLanguageChanged
                    
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
                    
                    onSelectedOptionChanged: {
                        _appConfig.set("default_task_type", selectedOption.value);
                        root.defaultTaskTypeChanged();
                    }
                }
            }
        }
    }
    
    function adjustTheme() {
        var theme = _appConfig.get("theme");
        themeToggle.checked = theme && theme === "DARK";
    }
    
    function adjustAskBeforeDeleting() {
        var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
        dontAskBeforeDeletingToggle.checked = doNotAsk && doNotAsk === "true";
    }
    
    function adjustSortBy() {
        var sortBy = _appConfig.get("sort_by");
        sortByNameOption.selected = sortBy === "" || sortBy === "name";
        sortByCreationOption.selected = sortBy === "id";
    }
    
    function adjustDefaultTaskType() {
        var defaultTaskType = _appConfig.get("default_task_type");
        folderOption.selected = defaultTaskType === "" || defaultTaskType === "FOLDER";
        taskOption.selected = defaultTaskType === "TASK";
    }
    
    onCreationCompleted: {
        adjustTheme();
        adjustAskBeforeDeleting();
        adjustSortBy();
        adjustDefaultTaskType();
    }
}