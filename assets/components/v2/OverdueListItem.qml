import bb.cascades 1.4

CustomListItem {
    id: root
    
    property int count: 0
    
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
            imageSource: "asset:///images/ic_overdue.png"
            filterColor: Color.create(_ui.color.skyBlue)
            maxWidth: ui.du(6)
            maxHeight: ui.du(6)
        }
        
        Label {
            verticalAlignment: VerticalAlignment.Center
            text: qsTr("Overdue") + Retranslate.onLocaleOrLanguageChanged
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
