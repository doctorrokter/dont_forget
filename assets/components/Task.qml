import bb.cascades 1.4
import "../sheets"

Container {
    id: task
    
    property int taskId: 1
    property bool expanded: true
    property bool expandable: true
    property bool important: false
    property bool closed: true
    property bool selected: false
    property int deadline: 0
    property string parentId: ""
    property string rememberId: ""
    property string type: "FOLDER"
    property string name: "Projects"
    
    property variant taskType: {
        FOLDER: "FOLDER",
        TASK: "TASK"
    }
    
    objectName: "task_" + taskId
    navigation.defaultHighlightEnabled: true
    navigation.focusPolicy: NavigationFocusPolicy.Focusable
    
    eventHandlers: [
        TrackpadHandler {
            onTrackpad: {
                if (event.trackpadEventType === TrackpadEventType.Press) {
                    console.debug('Trackpad pressed: ', taskId);
                    if (!task.selected) {
                        _tasksService.setActiveTask(task.taskId);
                    }
                    _app.taskSheetRequested();
                }
            }
        }
    ] 
    
    function getTaskIcon() {
        if (task.type === taskType.FOLDER) {
            return "asset:///images/ic_folder.png";
        } else if (task.type === taskType.TASK) {
            if (task.closed) {
                return "asset:///images/ic_done.png";
            }
            return "asset:///images/yellow_pellet.png";
        } else {
            return "";
        }
    }
    
    function getTaskIconColor() {
        if (task.type === taskType.FOLDER) {
            return ui.palette.primary;
        } else {
            if (task.closed) {
                return Color.create("#779933");
            }
        }
    }
    
    function getTaskIconMinHeight() {
        if (task.type === taskType.FOLDER) {
            return ui.du(4.5);
        }
        return ui.du(5.5);
    }
    
    function getTaskName() {
        var name = "<html>";
        if (task.closed) {
            name += "<span style=\"text-decoration: line-through;\">" + task.name +"</span>";
        } else {
            name += task.name;
        }
        
        if (task.important) {
            name += "<span style=\"color: #FF3333; font-size: 1em;\"> !</span>";
        }
        name += "</html>";
        return name;
    }
    
    horizontalAlignment: HorizontalAlignment.Fill
    
    Container {
        id: taskRoot
        
        leftPadding: ui.du(2)
        topPadding: ui.du(2)
        minHeight: ui.du(8)
        maxHeight: {
            if (task.expandable) {
                return task.expanded ? Infinity : ui.du(8);
            }
            return Infinity;
        }
        
        horizontalAlignment: HorizontalAlignment.Fill
        
        Container {
            id: taskBody
            objectName: "taskBody"
            
            horizontalAlignment: HorizontalAlignment.Fill
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            Container {
                background: selected ? ui.palette.plainBase : ui.palette.background
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                
                Container {
                    visible: task.expandable
                    verticalAlignment: VerticalAlignment.Center
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: -1
                    }
                    
                    ImageView {
                        imageSource: task.expanded ? "asset:///images/ic_minus.png" : "asset:///images/ic_plus.png"
                        maxWidth: ui.du(4)
                        maxHeight: ui.du(4)
                        filterColor: ui.palette.textOnPlain
                    }
                    
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                if (!task.selected) {
                                    _tasksService.setActiveTask(task.taskId);
                                }
                                
                                if (task.expandable) {
                                    task.expanded = !task.expanded;
                                    _tasksService.changeExpanded(task.taskId, task.expanded);
                                }
                            }
                        }
                    ]
                }
                
                Container {
                    leftPadding: task.expandable ? ui.du(1.5) : ui.du(3.5)
                    verticalAlignment: VerticalAlignment.Center
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: -1
                    }
                    
                    ImageView {
                        imageSource: getTaskIcon();
                        filterColor: getTaskIconColor();
                        maxWidth: ui.du(5.5)
                        maxHeight: getTaskIconMinHeight();
                    }
                }
                
                
                Container {
                    rightPadding: ui.du(1)
                    leftPadding: ui.du(1)
                    verticalAlignment: VerticalAlignment.Center
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    
                    Label {
                        opacity: task.closed ? 0.7 : 1.0
                        text: getTaskName();
                        textFormat: TextFormat.Html
                        textStyle.base: SystemDefaults.TextStyles.BodyText
                        verticalAlignment: VerticalAlignment.Center
                        multiline: true
                    }
                }
            }
            
            
            Container {
                horizontalAlignment: HorizontalAlignment.Right
                rightPadding: rememberId === "" ? ui.du(2.5) : ui.du(0)
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                layoutProperties: StackLayoutProperties {
                    spaceQuota: -1
                }
                
                Container {
                    visible: task.deadline !== 0
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        id: deadlineLabel
                        text: Qt.formatDateTime(new Date(task.deadline * 1000), "dd.MM.yyyy HH:mm")
                        textStyle.base: SystemDefaults.TextStyles.SmallText
                        textStyle.color: {
                            if ((task.deadline * 1000) < new Date().getTime()) {
                                return Color.create("#FF3333");
                            }
                            return ui.palette.textOnPlain;
                        }
                    }
                }
                
                CheckBox {
                    id: closeCheckBox
                    checked: task.closed
                    navigation.defaultHighlightEnabled: false
                    navigation.focusPolicy: NavigationFocusPolicy.NotFocusable
                    
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                if (!task.selected) {
                                    _tasksService.setActiveTask(task.taskId);
                                }
                                
                                task.closed = !task.closed;
                                _tasksService.changeClosed(task.taskId, task.closed);
                            }
                        }
                    ]            
                }    
                
                Container {
                    visible: rememberId !== ""
                    background: Color.DarkMagenta
                    minWidth: ui.du(0.5)
                    maxWidth: ui.du(0.5)
                    minHeight: ui.du(5)
                    maxHeight: ui.du(5)
                }
            }
            
            gestureHandlers: [
                TapHandler {
                    onTapped: {
                        if (!task.selected) {
                            _tasksService.setActiveTask(task.taskId);
                        }
                    }
                },
                
                DoubleTapHandler {
                    onDoubleTapped: {
                        if (!task.selected) {
                            _tasksService.setActiveTask(task.taskId);
                        }
                        taskSheet.mode = taskSheet.modes.UPDATE;
                        taskSheet.open();
                    }
                }          
            ]
        }
    }
    
    Divider {
        id: divider
    }
    
    function updateTask(updatedTask) {
        if (task.taskId === updatedTask.id) {
            task.important = updatedTask.important === 1;
            task.closed = updatedTask.closed === 1;
            task.deadline = updatedTask.deadline === "" ? 0 : updatedTask.deadline;
            task.rememberId = updatedTask.remember_id;
            task.type = updatedTask.type;
            task.name = updatedTask.name;
            task.expandable = isExpandable() || updatedTask.type === "FOLDER";
        }
    }
    
    function isExpandable() {
        var exp = false;
        for (var i = 0; i < taskRoot.controls.length; i++) {
            if (taskRoot.controls[i].objectName.indexOf('task_') !== -1) {
                exp = true;
            }
        }
        return exp;
    }
    
    function select() {
        task.selected = (_tasksService.activeTask !== null) && (_tasksService.activeTask.id === task.taskId);
    }
    
    function expand() {
        task.expanded = true;
    }
    
    function unexpand() {
        task.expanded = false;
    }
    
    function addChildTask(childTask) {
        taskRoot.add(childTask);
    }
    
    function changeViewMode(viewMode) {
        if (viewMode === "SHOW_ALL") {
            task.visible = true;
        } else {
            if (task.closed) {
                task.visible = false;
            }
        }
    }
    
    onParentIdChanged: {
        divider.visible = parentId === "";
    }
    
    onDeadlineChanged: {
        if (deadline !== 0) {
            deadlineLabel.text = Qt.formatDateTime(new Date(task.deadline * 1000), "dd.MM.yyyy HH:mm");
        } else {
            deadlineLabel.text = "";
        }
    }
    
    onCreationCompleted: {
        _tasksService.activeTaskChanged.connect(task.select);
        _tasksService.taskUpdated.connect(task.updateTask);
        _tasksService.allTasksExpanded.connect(task.expand);
        _tasksService.allTasksUnexpanded.connect(task.unexpand);
        _tasksService.viewModeChanged.connect(task.changeViewMode);
    }
    
    onControlRemoved: {
        _tasksService.activeTaskChanged.disconnect(task.select);
        _tasksService.taskUpdated.disconnect(task.updateTask);
        _tasksService.allTasksExpanded.disconnect(task.expand);
        _tasksService.allTasksUnexpanded.disconnect(task.unexpand);
        _tasksService.viewModeChanged.disconnect(task.changeViewMode);
    }
}
