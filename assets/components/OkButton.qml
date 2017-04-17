import bb.cascades 1.4
import bb.device 1.4

Container {
    id: root
    
    signal triggered();
    
    layout: DockLayout {}
    
    maxWidth: ui.du(12)
    maxHeight: ui.du(12)
    
    visible: isVisible()
    
    ImageView {
        id: image
        imageSource: "asset:///images/ok_button.png"
        maxWidth: root.maxWidth
        maxHeight: root.maxHeight
    }
    
    Label {
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        text: "OK"
        textStyle.color: ui.palette.textOnPrimary
    }
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                root.triggered();
            }
        }
    ]
    
    function show() {
        translationY = 0;
    }
    
    function hide() {
        translationY = -rootLUH.layoutFrame.height;
    }
    
    function isVisible() {
        if (hardware.isTrackpadDevice) {
            return true;
        } else {
            if (hardware.isPhysicalKeyboardDevice && hardware.modelName.indexOf('1440') === -1) {
                return true;
            } 
        }
        return false;
    }
    
    attachedObjects: [
        LayoutUpdateHandler {
            id: rootLUH
        },
        
        HardwareInfo {
            id: hardware
        }
    ]
}
