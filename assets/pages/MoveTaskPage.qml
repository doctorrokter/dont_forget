import bb.cascades 1.4
import "../components"

Page {
    id: root
    
    signal taskMove();
    
    property variant tasks: []
    
    titleBar: CustomTitleBar {
        title: _tasksService.activeTask.name
    }
    
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
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
                var data = tasksDataModel.data(indexPath);
                _tasksService.moveTask(data.id);
                taskMove();
            }
        }
    }
    
    function getTitle(tasksArray, id) {
        var task = findById(tasksArray, id);
        if (task.parent_id !== "") {
            var parent = findById(tasksArray, task.parent_id);
            if (parent) {
                return parent.name + " > " + task.name;
            }
        }
        return task.name;
    }
    
    function findById(tasksArray, id) {
        return tasksArray.filter(function(t) {
            return t.id === id;
        })[0];
    }
    
    onCreationCompleted: {
        tasksDataModel.clear();
        var tasksArray = _tasksService.findByType("FOLDER");
        tasksArray.forEach(function(t) {
            t.title = getTitle(tasksArray, t.id);
        });
        tasks = tasksArray;
    }
    
    onTasksChanged: {
        tasksDataModel.clear();
        tasksDataModel.append(tasks);
    }
}
