import bb.cascades 1.4

CustomListItem {
    
    id: root
    
    property int taskId: 0
    property string name: "Folder"
    property int parentId: 0
    property int count: 0
    property string color: ""
    
    signal openFolder(int taskId)
    
    dividerVisible: false
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                root.openFolder(root.taskId);
            }    
        }
    ]
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        background: ui.palette.background
        
        leftPadding: ui.du(2)
        rightPadding: ui.du(2)
        
        ImageView {
            verticalAlignment: VerticalAlignment.Center
            imageSource: "asset:///images/ic_folder.png"
            filterColor: {
                if (root.color !== "") {
                    return Color.create(root.color);
                }
                return ui.palette.primaryBase;
            }
            maxWidth: ui.du(6)
            maxHeight: ui.du(6)
        }
        
        Label {
            verticalAlignment: VerticalAlignment.Center
            text: root.name
            textStyle.base: SystemDefaults.TextStyles.PrimaryText
            multiline: true
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
        
        Label {
            verticalAlignment: VerticalAlignment.Center
            text: root.count === 0 ? "" : root.count
            textStyle.color: ui.palette.secondaryTextOnPlain
        }
    }
}
