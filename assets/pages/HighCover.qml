import bb.cascades 1.4
import "../components"
import "../components/v2"
import "../js/Const.js" as Const

Container {
    id: root
    
    horizontalAlignment: HorizontalAlignment.Fill
    
    layout: DockLayout {}

    ImageView {
        imageSource: _ui.backgroundImage
        scalingMethod: ScalingMethod.AspectFill
        opacity: 0.75
    }    
    
    ListView {
        id: listView
        
        dataModel: ArrayDataModel {
            id: dataModel
        }
        
        function itemType(data, indexPath) {
            return data.type;
        }
        
        listItemComponents: [
            ListItemComponent {
                type: Const.TaskTypes.LIST
                ListCoverListItem {
                    name: ListItemData.name
                    deadline: ListItemData.deadline
                    color: ListItemData.color
                }    
            },
            
            ListItemComponent {
                type: Const.TaskTypes.TASK
                TaskCoverListItem {
                    name: ListItemData.name
                    deadline: ListItemData.deadline
                }
            }
        ]
    }
    
    Container {
        id: noTasksContainer
        
        visible: false
        verticalAlignment: VerticalAlignment.Center
        horizontalAlignment: HorizontalAlignment.Center
        
        Label {
            text: qsTr("No tasks for today") + Retranslate.onLocaleOrLanguageChanged
            textStyle.base: SystemDefaults.TextStyles.BigText
            textStyle.color: ui.palette.textOnPrimary
            multiline: true
        }
    }
    
    function update() {
        dataModel.clear();
        var tasks = _tasksService.findTodayTasks();
        noTasksContainer.visible = tasks.length === 0;
        dataModel.append(tasks);
    }
}
