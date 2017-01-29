import bb.cascades 1.4

Container {
    id: root
    
    property bool expanded: true
    
    verticalAlignment: VerticalAlignment.Center
    
    leftPadding: ui.du(1)
    topPadding: ui.du(1)
    bottomPadding: ui.du(1)
    
    ImageView {
        imageSource: root.expanded ? "asset:///images/ic_minus.png" : "asset:///images/ic_plus.png"
        maxWidth: ui.du(2.5)
        maxHeight: ui.du(2.5)
        filterColor: ui.palette.textOnPlain
    }
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                root.expanded = !root.expanded;
            }
        }
    ]
}
