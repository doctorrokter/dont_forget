import bb.cascades 1.4

Container {
    id: root
    
    signal clicked(string color)
    
    property string color: _ui.color.skyBlue
    property bool checked: false
    
    background: Color.create(root.color);
    preferredWidth: ui.du(15)
    preferredHeight: ui.du(15)
    
    layout: DockLayout {}
    
    margin.leftOffset: ui.du(0.5)
    margin.topOffset: ui.du(0.5)
    margin.rightOffset: ui.du(0.5)
    margin.bottomOffset: ui.du(0.5)
    
    ImageView {
        id: image
        
        verticalAlignment: VerticalAlignment.Center
        horizontalAlignment: HorizontalAlignment.Center
        imageSource: "asset:///images/ic_done.png"
        maxWidth: ui.du(10)
        maxHeight: ui.du(10)
        scaleX: image.visible ? 1 : 0
        scaleY: image.visible ? 1 : 0
        
        animations: [
            ScaleTransition {
                id: increase
                    
                duration: 150
                fromX: 0
                fromY: 0
                
                toX: 1
                toY: 1
                
                onStarted: {
                    image.visible = true;
                }
            },
            
            ScaleTransition {
                id: decrease
                
                duration: 150
                fromX: 1
                fromY: 1
                
                toX: 0
                toY: 0
                
                onEnded: {
                    image.visible = false;
                }
            }
        ]
    }
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                clicked(root.color);
            }
        }
    ]
    
    onCreationCompleted: {
        image.visible = root.checked;
    }
    
    onCheckedChanged: {
        if (checked) {
            increase.play();
        } else {
            decrease.play();
        }
    }
}
