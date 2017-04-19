import bb.cascades 1.4
import bb.system 1.2
import "../components"

Page {
    id: root
    
    signal taskChosen(variant chosenTask);
    
    property bool searchMode: false
    property variant tasks: []
    
    titleBar: defaultTitleBar
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    ListView {
        id: tasksListView
        
        scrollRole: ScrollRole.Main
        
        dataModel: ArrayDataModel {
            id: tasksDataModel
        }
        
        listItemComponents: [
            ListItemComponent {
                CustomListItem {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    visible: ListItemData.visible
                    
                    Container {
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        leftPadding: ui.du(2.5)
                        
                        ImageView {
                            imageSource: ListItemData.type === "FOLDER" ? "asset:///images/ic_folder.png" : "asset:///images/ic_list.png"
                            filterColor: ListItemData.type === "FOLDER" ? ui.palette.primary : Color.create("#779933");
                            maxWidth: ui.du(8)
                            maxHeight: ui.du(6.5)
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: -1
                            }
                        }
                        
                        Label {
                            verticalAlignment: VerticalAlignment.Center
                            text: ListItemData.title
                            textStyle.base: SystemDefaults.TextStyles.PrimaryText
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                        }
                    }
                }
            }
        ]
        
        onTriggered: {
            taskChosen(tasksDataModel.data(indexPath));
        }
    }
    
    attachedObjects: [
        CustomTitleBar {
            id: defaultTitleBar
            title: qsTr("Choose a folder") + Retranslate.onLocaleOrLanguageChanged
        },
        
        InputTitleBar {
            id: inputTitleBar
            
            onCancel: {
                root.searchMode = false;
            }
            
            onTyping: {
                var filteredTasks = tasks.filter(function(t) {
                    return t.title.toLowerCase().indexOf(text.toLowerCase()) !== -1;
                });
                tasksDataModel.clear();
                tasksDataModel.append(filteredTasks);
            }
        },
        
        SystemPrompt {
            id: prompt
            title: qsTr("Create a folder") + Retranslate.onLocaleOrLanguageChanged
            inputField.inputMode: SystemUiInputMode.Default
            inputField.maximumLength: 50
            
            onFinished: {
                console.debug(value);
                if (value === 2) {
                    var name = prompt.inputFieldTextEntry();
                    _tasksService.createFolderQuick(name);
                }
            }
        }
    ]
    
    actions: [
        ActionItem {
            id: searchActionItem
            title: qsTr("Search") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.Signature
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
                root.searchMode = true;
            }
        },
        
        ActionItem {
            id: createActionItem
            title: qsTr("Create") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_add.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                prompt.show();
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                    
                    onTriggered: {
                        createActionItem.triggered();
                    }
                }
            ]
        }
    ]
    
    function getTitle(tasksArray, id) {
        var task = findById(tasksArray, id);
        if (task.parent_id !== "") {
            var parent = findById(tasksArray, task.parent_id);
            if (parent) {
                return parent.name + " > " + task.name;
            } else {
                return "No parent, but has parent_id > " + task.name;
            }
        }
        return task.name;
    }
    
    function findById(tasksArray, id) {
        return tasksArray.filter(function(t) {
            return t.id === id;
        })[0];
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
    
    function removeChildrenFromArray(tasksArray, task) {
        root.tasks = tasksArray.filter(function(t) {
                return t.id !== task.id;
        });
        if (task.children.length !== 0) {
            task.children.forEach(function(t) {
                removeChildrenFromArray(root.tasks, t);
            });
        }
    }
    
    function fill() {
        tasksDataModel.clear();
        tasksDataModel.append({id: 0, type: "FOLDER", title: qsTr("Root") + Retranslate.onLocaleOrLanguageChanged});
        tasksDataModel.append(tasks);
    }
    
    function addNewFolder(task) {
        task.title = task.name;
        tasksDataModel.insert(1, task);
    }
    
    onCreationCompleted: {
        tasksDataModel.clear();
        var tasksArray = _tasksService.findAll();
        
        tasksArray = tasksArray.map(function(t) {
            t.title = getTitle(tasksArray, t.id);
            if (_tasksService.activeTask) {
                t.visible = (t.id !== _tasksService.activeTask.id) && (t.type === "FOLDER" || t.type === "LIST");
            } else {
                t.visible = (t.type === "FOLDER" || t.type === "LIST");
            }
            return t;
        });
    
        tasksArray.forEach(function(t) {
            children(tasksArray, t);  
        });
        
        if (_tasksService.activeTask) {
            var currTask = findById(tasksArray, _tasksService.activeTask.id);
            removeChildrenFromArray(tasksArray, currTask);
        } else {
            root.tasks = tasksArray;
        }
        _tasksService.quickFolderCreated.connect(root.addNewFolder);
    }
    
    onTasksChanged: {
        fill();
    }
    
    onSearchModeChanged: {
        if (root.searchMode) {
            root.titleBar = inputTitleBar;
            root.titleBar.focus();
        } else {
            root.titleBar.reset();
            root.titleBar = defaultTitleBar;
            fill();
        }
    }
}
