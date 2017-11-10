import bb.cascades 1.4
import "../../js/Const.js" as Const

CustomListItem {
    
    id: root
    
    property string name: ""
    property int deadline: 0
    property string color: ""
    
    dividerVisible: false
    
    function getTaskName() {
        var n = root.name
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/\"/g, "&quot;");
        var name = "<html>";
        name += n;
        name += "</html>";
        return name;
    }
    
    maxHeight: ui.du(8)
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        background: ui.palette.background
        margin.leftOffset: ui.du(1)
        margin.topOffset: ui.du(1)
        margin.rightOffset: ui.du(1)
        
        leftPadding: ui.du(0.5)
        rightPadding: ui.du(0.5)
        
        Container {
            background: ui.palette.background
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            ImageView {
                verticalAlignment: VerticalAlignment.Center
                imageSource: "asset:///images/ic_notes.png"
                filterColor: {
                    if (root.color !== "") {
                        return Color.create(root.color);
                    }
                    return Color.create(_ui.color.darkYellow);
                }
                maxWidth: ui.du(4)
                maxHeight: ui.du(4)
            }
            
            Label {
                verticalAlignment: VerticalAlignment.Top
                text: root.getTaskName()
                textStyle.base: SystemDefaults.TextStyles.SubtitleText
                textFormat: TextFormat.Html
                multiline: true
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
        }
        
        Container {
            background: ui.palette.background
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            
            Label {
                verticalAlignment: VerticalAlignment.Center
                text: _date.str(root.deadline);
                textStyle.base: SystemDefaults.TextStyles.SmallText
                textStyle.color: {
                    if ((root.deadline * 1000) < new Date().getTime()) {
                        return Color.create(_ui.color.brickRed);
                    }
                    return ui.palette.secondaryTextOnPlain;
                }
            }
        }
    }
}

