import bb.cascades 1.4
import "../"

CustomListItem {
    
    id: root
    
    property int taskId: 0
    property string name: "Task"
    property string description: ""
    property int deadline: 1231234235
    property bool important: false
    property bool closed: false
    property int parentId: 0
    property int rememberId: 0
    property int calendarId: 0
    property variant attachments: []
    property bool expanded: false
    
    property int startMove: 0
    
    signal openTask(int taskId)
    signal taskRemoved(int taskId)
    
    animations: [
        ScaleTransition {
            id: scaling
            toX: 0.25
            toY: 0.25
            fromX: 1
            fromY: 1
            
            duration: 150
            
            onEnded: {
                root.scaleX = 1;
                root.scaleY = 1;
                root.translationX = 0;
                root.taskRemoved(root.taskId);
            }
        }
    ]
    
    onTouch: {
        if (event.isDown()) {
            root.startMove = event.windowX;
        }
        
        if (event.isMove()) {
            if ((root.startMove - event.windowX) > 75) {
                root.translationX = event.windowX - root.startMove;
            }
        }
        
        if (event.isUp() || event.isCancel()) {
            if (root.translationX <= -400) {
                root.translationX = 0;
                scaling.play();
            }
            root.translationX = 0;
        }
    }
    
    dividerVisible: false
    
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
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                root.openTask(root.taskId);
            }    
        },
        
        DoubleTapHandler {
            onDoubleTapped: {
                root.expanded = !root.expanded;
            }
        }
    ]
    
    Container {
        
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        leftPadding: ui.du(2)
        topPadding: ui.du(2)
        rightPadding: ui.du(2)
        
        opacity: root.closed ? 0.75 : 1
        
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            background: ui.palette.background
            
            leftPadding: ui.du(2)
            topPadding: ui.du(2)
            rightPadding: ui.du(2)
            bottomPadding: ui.du(2)
            
            Label {
                opacity: root.closed ? 0.7 : 1.0
                verticalAlignment: VerticalAlignment.Top
                text: root.getTaskName()
                textStyle.base: SystemDefaults.TextStyles.PrimaryText
                textFormat: TextFormat.Html
                multiline: true
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
            }
            
            CheckBox {
                verticalAlignment: VerticalAlignment.Top
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
            horizontalAlignment: HorizontalAlignment.Fill
            
            background: ui.palette.background
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            leftPadding: ui.du(2)
            rightPadding: ui.du(1)
            bottomPadding: ui.du(1)
            
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
            
            Container {
                visible: root.important
                verticalAlignment: VerticalAlignment.Center
                
                ImageView {
                    maxWidth: ui.du(3.5)
                    maxHeight: ui.du(3.5)
                    imageSource: "asset:///images/ic_white_pellet.png"
                    filterColor: Color.create(_ui.color.brickRed)
                }
            }
            
            Container {
                visible: root.rememberId !== "" && root.rememberId !== 0
                verticalAlignment: VerticalAlignment.Center
                ImageView {
                    maxWidth: ui.du(3.5)
                    maxHeight: ui.du(3.5)
                    imageSource: "asset:///images/ic_white_pellet.png"
                    filterColor: Color.DarkMagenta
                }
            }
            
            Container {
                visible: root.calendarId !== 0
                verticalAlignment: VerticalAlignment.Center
                ImageView {
                    maxWidth: ui.du(3.5)
                    maxHeight: ui.du(3.5)
                    imageSource: "asset:///images/ic_white_pellet.png"
                    filterColor: Color.create(_ui.color.darkGreen)
                }
            }
            
            Container {
                visible: root.attachments.length !== 0
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    ImageView {
                        verticalAlignment: VerticalAlignment.Center
                        maxWidth: ui.du(3.5)
                        maxHeight: ui.du(3.5)
                        imageSource: "asset:///images/ic_attach.png"
                        filterColor: ui.palette.secondaryTextOnPlain
                    }
                }
                
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        verticalAlignment: VerticalAlignment.Center
                        text: "+" + root.attachments.length
                        textStyle.color: ui.palette.secondaryTextOnPlain
                        textStyle.base: SystemDefaults.TextStyles.SubtitleText
                    }
                }
            }
        }
        
        Container {
            id: descriptionContainer
            
            visible: root.description !== "" && root.expanded
            horizontalAlignment: HorizontalAlignment.Fill
            background: ui.palette.background
            
            leftPadding: ui.du(2)
            rightPadding: ui.du(1)
            bottomPadding: ui.du(1)
            
            Divider {}
            
            Label {
                text: root.description
                multiline: true
            }
            
            Container {
                id: previews
            }
        }
        
        AttachmentsContainer {
            id: attachmentsContainer
            attachments: root.attachments
            background: ui.palette.background
            fromListItem: true
            visible: root.attachments.length > 0 && root.expanded
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: richLinkPreview
            RichLinkPreview {}
        }
    ]
    
    onDescriptionChanged: {
        previews.removeAll();
        var urls = description.match(/\bhttps?:\/\/\S+/gi);
        if (urls) {
            urls.forEach(function(url) {
                var preview = richLinkPreview.createObject();
                preview.url = url;
                previews.add(preview);
            });
        }
    }
}
