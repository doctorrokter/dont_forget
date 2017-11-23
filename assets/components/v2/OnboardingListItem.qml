import bb.cascades 1.4
import bb.device 1.4
import "../"

CustomListItem {
    id: root
    
    property int screenWidth: 1440
    property int screenHeight: 1440
    property string title: ""
    property string imageSource: ""
    property string description: ""
    property string color: ""
    property variant textColor
    property bool last: false
    
    highlightAppearance: HighlightAppearance.None
    
    preferredWidth: ListItem.view.width
    preferredHeight: ListItem.view.height
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ColorContainer {
            color: root.color
        }
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            margin.topOffset: ui.du(5)
            Label {
                text: root.title
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.base: SystemDefaults.TextStyles.BigText
                textStyle.color: root.textColor
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                ImageView {
                    horizontalAlignment: HorizontalAlignment.Center
                    imageSource: root.imageSource
                    scalingMethod: ScalingMethod.AspectFit
                    margin.leftOffset: ui.du(5)
                    margin.rightOffset: ui.du(5)
                    maxWidth: {
                        if (root.deviceIsSmall()) {
                            return ui.du(35);
                        } else if (root.deviceIsBig()) {
                            return ui.du(70);
                        } else {
                            return ui.du(65);
                        }
                    }
                }
            }
            
            Label {
                horizontalAlignment: HorizontalAlignment.Center
                text: root.description
                multiline: true
                textStyle.color: root.textColor
            }
        }
        
        SwipeContainer {
            visible: !root.last    
            textColor: root.textColor
        }
        
        Button {
            id: doneButton
            visible: root.last
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            margin.bottomOffset: ui.du(2)
            text: qsTr("Done!") + Retranslate.onLocaleOrLanguageChanged
            
            onClicked: {
                _app.tutorialDone();
            }
        }
    }
    
    function deviceIsSmall() {
        return root.screenWidth === 720 && root.screenHeight === 720;
    }
    
    function deviceIsBig() {
        return root.screenWidth === 1440 && root.screenHeight === 1440;
    }
    
    attachedObjects: [
        DisplayInfo {
            id: display
        }
    ]
    
    onCreationCompleted: {
        root.screenWidth = display.pixelSize.width;
        root.screenHeight = display.pixelSize.height;
    }
}
