import bb.cascades 1.4

CustomListItem {
    id: root
    
    property int count: 0
    property string imageSource: ""
    property string title: ""
    property string color: ""
    
    signal open()
    
    dividerVisible: false
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                root.open();
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
            imageSource: root.imageSource
            filterColor: Color.create(root.color)
            maxWidth: ui.du(6)
            maxHeight: ui.du(6)
        }
        
        Label {
            verticalAlignment: VerticalAlignment.Center
            text: root.title
            textStyle.base: SystemDefaults.TextStyles.PrimaryText
            
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
