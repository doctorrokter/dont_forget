import bb.cascades 1.4
import "../sheets"
import "../pages"

Container {
    id: task
    
    signal taskViewRequested();
          
    property int taskId: 1
    property bool expanded: true
    property bool expandable: false
    property bool important: false
    property bool closed: true
    property bool selected: _tasksService.isTaskSelected(taskId)
    property int deadline: 0
    property string parentId: ""
    property string rememberId: ""
    property int calendarId: 87687687
    property string type: "TASK"
    property string name: "RELAX ~ Zdravnisko £ spricevalo & < > \" kartica"
    
    property variant taskType: {
        FOLDER: "FOLDER",
        TASK: "TASK",
        LIST: "LIST"
    }
    
    objectName: "task_" + taskId
    navigation.defaultHighlightEnabled: true
    navigation.focusPolicy: NavigationFocusPolicy.Focusable
    
    eventHandlers: [
        TrackpadHandler {
            onTrackpad: {
                if (event.trackpadEventType === TrackpadEventType.Press) {
                    if (!task.selected) {
                        _tasksService.setActiveTask(task.taskId);
                    }
                    taskViewRequested();
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
        } else if (task.type === taskType.LIST) {
            return "asset:///images/ic_list.png";
        } else {
            return "";
        }
    }
    
    function getTaskIconColor() {
        if (task.type === taskType.FOLDER) {
            return ui.palette.primary;
        } else if (task.type === taskType.LIST) {
            return Color.create("#779933");
        } else {
            if (task.closed) {
                return Color.create("#779933");
            }
        }
    }
    
    function getTaskIconMinHeight() {
        if (task.type === taskType.FOLDER) {
            return ui.du(4.5);
        } else if (task.type === taskType.LIST) {
            return ui.du(5);
        }
        return ui.du(5.5);
    }
    
    function getTaskName() {
        var n = task.name
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/\"/g, "&quot;");
        var name = "<html>";
        if (task.closed) {
            name += "<span style=\"text-decoration: line-through;\">" + n +"</span>";
        } else {
            name += n;
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
                                if (!_tasksService.multiselectMode) {
                                    if (!task.selected) {
                                        _tasksService.setActiveTask(task.taskId);
                                    }
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
                        verticalAlignment: VerticalAlignment.Center
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
                rightPadding: rememberId === "" && calendarId === "" ? ui.du(2.5) : ui.du(0)
                
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
                    margin.rightOffset: {
                        if (calendarId === 0 && rememberId === "") {
                            return ui.du(3);
                        } else if (calendarId === 0 || rememberId === "") {
                            return ui.du(0.5);
                        } else {
                            return 0;
                        }
                    }
                    
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                if (!task.selected) {
                                    if (!_tasksService.multiselectMode) {
                                        _tasksService.setActiveTask(task.taskId);
                                    } else {
                                        _tasksService.selectTask(task.taskId);
                                    }
                                }
                                
                                task.closed = !task.closed;
                                _tasksService.changeClosed(task.taskId, task.closed);
                            }
                        }
                    ]            
                }    
                
                Container {
                    visible: calendarId !== 0
                    background: Color.create("#779933")
                    minWidth: ui.du(0.5)
                    maxWidth: ui.du(0.5)
                    minHeight: ui.du(5)
                    maxHeight: ui.du(5)
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
                        if (!_tasksService.multiselectMode) {
                            if (!task.selected) {
                                _tasksService.setActiveTask(task.taskId);
                            }
                        } else {
                            if (!task.selected) {
                                _tasksService.selectTask(task.taskId);
                            } else {
                                _tasksService.deselectTask(task.taskId);
                            }
                        }
                    }
                },
                
                DoubleTapHandler {
                    onDoubleTapped: {
                        if (!task.selected) {
                            if (!_tasksService.multiselectMode) {
                                _tasksService.setActiveTask(task.taskId);
                            } else {
                                _tasksService.selectTask(task.taskId);
                            }
                        }
                        taskViewRequested();
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
            task.calendarId = updatedTask.calendar_id;
            task.type = updatedTask.type;
            task.name = updatedTask.name;
            task.expandable = isExpandable(updatedTask);
        }
    }
    
    function isExpandable(task) {
        var exp = false;
        for (var i = 0; i < taskRoot.controls.length; i++) {
            if (taskRoot.controls[i].objectName.indexOf('task_') !== -1) {
                exp = true;
            }
        }
        return exp ? exp : (task.type === "FOLDER" || task.type === "LIST");
    }
    
    function select(id) {
        if (_tasksService.multiselectMode) {
            if (task.taskId === id) {
                task.selected = !task.selected;
            }
        } else {
            task.selected = (_tasksService.activeTask !== null) && (_tasksService.activeTask.id === task.taskId);
        }
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
    
    function clear() {
        console.debug("clear");
        _tasksService.activeTaskChanged.disconnect(task.select);
        _tasksService.taskUpdated.disconnect(task.updateTask);
        _tasksService.allTasksExpanded.disconnect(task.expand);
        _tasksService.allTasksUnexpanded.disconnect(task.unexpand);
        _tasksService.viewModeChanged.disconnect(task.changeViewMode);
        _tasksService.taskSelected.disconnect(task.select);
        _tasksService.taskDeselected.disconnect(task.select);
        _tasksService.multiselectModeChanged.disconnect(task.handleMultiselectModeChanged);
    }
    
    function handleMultiselectModeChanged(multiselectMode) {
        if (!multiselectMode) {
            if (task.selected) {
                task.selected = false;
            }
        }
    }
    
    function dropRememberId(id) {
        if (taskId === id) {
            rememberId = "";
        }
    }
    
    function dropCalendarId(id) {
        if (taskId === id) {
            calendarId = 0;
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
        _tasksService.taskSelected.connect(task.select);
        _tasksService.taskDeselected.connect(task.select);
        _tasksService.multiselectModeChanged.connect(task.handleMultiselectModeChanged);
        _tasksService.droppedRememberId.connect(task.dropRememberId);
        _tasksService.droppedCalendarId.connect(task.dropCalendarId);
    }
    
    onControlRemoved: {
        clear();
    }
    
    onSelectedChanged: {
        if (selected) {
            _signal.play();
        }
    }
}
