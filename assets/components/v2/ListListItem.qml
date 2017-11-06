import bb.cascades 1.4

CustomListItem {
    
    id: root
    
    property int taskId: 0
    property string name: "List"
    property int parentId: 0
    property int count: 0
    property string color: ""
    property int deadline: 0
    property bool closed: false
    property int rememberId: 0
    property int calendarId: 0
    property bool expanded: false
    
    signal openList(int taskId)
    
    dividerVisible: false
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                root.openList(root.taskId);
            }    
        }
    ]
    
    function getTaskName() {
        var n = root.name
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/\"/g, "&quot;");
        var name = "<html>";
        if (root.closed) {
            name += "<span style=\"text-decoration: line-through;\">" + n +"</span>";
        } else {
            name += n;
        }
        name += "</html>";
        return name;
    }
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        background: ui.palette.background
        
//        leftPadding: ui.du(2)
//        topPadding: ui.du(1.5)
//        rightPadding: ui.du(2)
        
        opacity: root.closed ? 0.75 : 1
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            
            leftPadding: ui.du(2)
            topPadding: ui.du(1.5)
            rightPadding: ui.du(2)
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            background: ui.palette.background
            
            ImageView {
                verticalAlignment: VerticalAlignment.Center
                imageSource: "asset:///images/ic_notes.png"
                filterColor: {
                    if (root.color !== "") {
                        return Color.create(root.color);
                    }
                    return Color.create("#B7B327");
                }
                maxWidth: ui.du(6)
                maxHeight: ui.du(6)
            }
            
            Label {
                verticalAlignment: VerticalAlignment.Center
                text: root.getTaskName()
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
            
            CheckBox {
                verticalAlignment: VerticalAlignment.Center
                checked: root.closed
                
                onCheckedChanged: {
                    if (root.closed !== checked) {
                        root.closed = checked;
                        _tasksService.changeClosed(root.taskId, root.closed, root.parentId);
                    }
                }
            }
        }
        
        Container {
            verticalAlignment: VerticalAlignment.Center
            background: ui.palette.background
            
            visible: root.deadline !== 0
            
            leftPadding: ui.du(2.5)
            topPadding: ui.du(1.5)
            rightPadding: ui.du(2)
            bottomPadding: ui.du(1)
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                
                ImageView {
                    visible: root.deadline !== 0
                    verticalAlignment: VerticalAlignment.Center
                    imageSource: "asset:///images/ic_history.png"
                    maxWidth: ui.du(5)
                    maxHeight: ui.du(5)
                    filterColor: {
                        if ((root.deadline * 1000) < new Date().getTime()) {
                            return Color.create("#CC3333");
                        }
                        return ui.palette.secondaryTextOnPlain;
                    }
                }
                
                Label {
                    verticalAlignment: VerticalAlignment.Center
                    text: root.deadline === 0 ? "" : _date.str(root.deadline);
                    textStyle.base: SystemDefaults.TextStyles.SubtitleText
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
    
}
