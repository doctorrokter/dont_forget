import bb.cascades 1.4
import "../../actions"

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
    property bool selected: false
    property ListView listView: ListItem.view
    
    signal openList(int taskId)
    
    dividerVisible: false
    opacity: ListItem.selected || root.selected ? 0.85 : 1
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                if (!root.ListItem.selected && !root.selected) {
                    root.openList(root.taskId);
                }
            }    
        },
        
        DoubleTapHandler {
            onDoubleTapped: {
                // TODO: make some work
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
        
        background: {
            if (Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright) {
                return ui.palette.background;
            }
            return ui.palette.plain;
        }
        
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
            
            background: {
                if (Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright) {
                    return ui.palette.background;
                }
                return ui.palette.plain;
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
                            return Color.create(_ui.color.brickRed);
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
                            return Color.create(_ui.color.brickRed);
                        }
                        return ui.palette.secondaryTextOnPlain;
                    }
                }
            }
        }
    }
    
    contextActions: [
        ActionSet {
            title: qsTr("Actions") + Retranslate.onLocaleOrLanguageChanged
            MoveActionItem {
                listView: root.listView
            }
            
            DeleteTaskActionItem {
                listView: root.listView
            }
            
            SendActionItem {
                taskId: root.taskId
                listView: root.listView
            }
            
            RememberActionItem {
                listView: root.listView
                enabled: root.rememberId !== 0
            }
            
            CalendarActionItem {
                listView: root.listView
                enabled: root.calendarId !== 0
            }
        }
    ]
}
