import bb.cascades 1.4
import "../../js/Const.js" as Const

CustomListItem {
    id: root
    
    property int parentId: ListItemData
    property variant task
    
    signal openFolder(int taskId)
    signal openList(int taskId)
    
    preferredHeight: ui.du(8)
    dividerVisible: false
    
    margin.topOffset: ui.du(2)
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                if (root.task.type === Const.TaskTypes.LIST) {
                    root.openList(root.task.id);
                } else if (task.type === Const.TaskTypes.FOLDER) {
                    root.openFolder(root.task.id);
                }
            }    
        }
    ]
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        background: ui.palette.plain
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        leftPadding: ui.du(1)
        topPadding: ui.du(1)
        rightPadding: ui.du(1)
        bottomPadding: ui.du(1)
        
        ImageView {
            id: image
            verticalAlignment: VerticalAlignment.Center
            maxWidth: ui.du(6)
            maxHeight: ui.du(6)
        }
        
        Label {
            id: title
            text: ""
            verticalAlignment: VerticalAlignment.Center
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
    }
    
    onParentIdChanged: {
        if (parentId !== -1) {
            root.task = _tasksService.findById(parentId);
            title.text = task.name;
            if (root.task.type === Const.TaskTypes.FOLDER) {
                image.imageSource = "asset:///images/ic_folder.png";
                if (task.color !== "") {
                    image.filterColor = Color.create(root.task.color);
                } else {
                    image.filterColor = ui.palette.primaryBase;
                }
            } else if (root.task.type === Const.TaskTypes.LIST) {
                image.imageSource = "asset:///images/ic_notes.png";
                if (root.task.color !== "") {
                    image.filterColor = Color.create(root.task.color);
                } else {
                    image.filterColor = Color.create("#B7B327");
                }
            }
        } else {
            title.text = qsTr("Root") + Retranslate.onLocaleOrLanguageChanged                                    
        }
    }
}