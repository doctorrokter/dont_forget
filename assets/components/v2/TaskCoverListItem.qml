import bb.cascades 1.4
import "../../js/Const.js" as Const

CustomListItem {
    
    id: root
    
    property string name: ""
    property int deadline: 0
    
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
    
    preferredHeight: ui.du(8)
    maxHeight: ui.du(12)
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        margin.leftOffset: ui.du(1)
        margin.topOffset: ui.du(1)
        margin.rightOffset: ui.du(1)
        
        leftPadding: ui.du(0.5)
        rightPadding: ui.du(0.5)
        
        background: ui.palette.background
        
        Container {
            background: ui.palette.background
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
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
                        return Color.create("#CC3333");
                    }
                    return ui.palette.secondaryTextOnPlain;
                }
            }
        }
    }
}
