import bb.cascades 1.4
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
                            imageSource: "asset:///images/ic_folder.png"
                            filterColor: ui.palette.primary
                            maxWidth: ui.du(8)
                            maxHeight: ui.du(6.5)
                        }
                        
                        Label {
                            verticalAlignment: VerticalAlignment.Center
                            text: ListItemData.title
                            textStyle.base: SystemDefaults.TextStyles.PrimaryText
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
                    return t.name.toLowerCase().indexOf(text.toLowerCase()) !== -1;
                });
                tasksDataModel.clear();
                tasksDataModel.append(filteredTasks);
            }
        }
    ]
    
    actions: [
        ActionItem {
            title: qsTr("Search") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "asset:///images/ic_search.png"
            
            onTriggered: {
                root.searchMode = true;
            }
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
        tasksDataModel.append({id: 0, title: qsTr("Root") + Retranslate.onLocaleOrLanguageChanged});
        tasksDataModel.append(tasks);
    }
    
    onCreationCompleted: {
        tasksDataModel.clear();
        var tasksArray = _tasksService.findAll();
        
        tasksArray = tasksArray.map(function(t) {
            t.title = getTitle(tasksArray, t.id);
            if (_tasksService.activeTask) {
                t.visible = (t.id !== _tasksService.activeTask.id) && (t.type === "FOLDER");
            } else {
                t.visible = t.type === "FOLDER";
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
