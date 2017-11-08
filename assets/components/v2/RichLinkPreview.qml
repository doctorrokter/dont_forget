import bb.cascades 1.4
import WebPageComponent 1.0

Container {
    id: root
    
    property string url: ""
    property string site: "Onliner.by"
    property string title: ""
    property string description: "The mega description for the super link"
    property string imageSource: "asset:///images/backgrounds/AndroidXWallpaper(Wall2mob.com)_40131.jpg"
    
    horizontalAlignment: HorizontalAlignment.Fill
    
    leftPadding: ui.du(1)
    topPadding: ui.du(1)
    rightPadding: ui.du(1)
    
    Container {
        bottomMargin: ui.du(1)
        Label {
            text: "<a href=\"" + root.url + "\">" + root.url + "</a>"
            textFormat: TextFormat.Html
        }
    }
    
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        Container {
            preferredWidth: ui.du(0.75)
            preferredHeight: mainLUH.layoutFrame.height
            background: ui.palette.primaryBase
        }
        
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            
            leftPadding: ui.du(1)
            
            Container {
                Label {
                    text: root.site
                    textStyle.color: ui.palette.primaryBase
                }
            }
            
            Container {
                Label {
                    text: root.title
                    multiline: true
                    textStyle.fontWeight: FontWeight.W600
                }
            }
            
            Container {
                Label {
                    text: root.description
                    textFormat: TextFormat.Html
                }
            }
            
            ImageView {
                horizontalAlignment: HorizontalAlignment.Fill
                imageSource: root.imageSource
                scalingMethod: ScalingMethod.AspectFill
                maxHeight: ui.du(35)
            }
            
            attachedObjects: [
                LayoutUpdateHandler {
                    id: mainLUH
                }
            ]
        }
    }
}
