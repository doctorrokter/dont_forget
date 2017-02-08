import bb.cascades 1.4
import "../components"

Page {
    id: root
    
    signal taskMove();
    
    property variant tasks: []
    
    titleBar: CustomTitleBar {
        title: qsTr("Move task") + Retranslate.onLocaleOrLanguageChanged
    }
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layout: DockLayout {}
        
        ActivityIndicator {
            id: spinner
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            preferredWidth: ui.du(10)
        }
        
        ListView {
            id: tasksListView
            
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
                spinner.running = true;
                var data = tasksDataModel.data(indexPath);
                if (_tasksService.activeTask.parentId !== data.id) {
                    _tasksService.moveTask(data.id);
                }
                taskMove();
                spinner.running = false;
            }
        }
    }
    
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
    
    onCreationCompleted: {
        tasksDataModel.clear();
        var tasksArray = _tasksService.findAll();
        
        tasksArray = tasksArray.map(function(t) {
            t.title = getTitle(tasksArray, t.id);
            t.visible = (t.id !== _tasksService.activeTask.id) && (t.type === "FOLDER");
            return t;
        });
        
        tasksArray.forEach(function(t) {
            children(tasksArray, t);  
        });
        
        var currTask = findById(tasksArray, _tasksService.activeTask.id);
        removeChildrenFromArray(tasksArray, currTask);
    }
    
    onTasksChanged: {
        tasksDataModel.clear();
        if (_tasksService.activeTask.parentId) {
            tasksDataModel.append({id: 0, title: qsTr("Root") + Retranslate.onLocaleOrLanguageChanged});
        }
        tasksDataModel.append(tasks);
    }
}
