import bb.cascades 1.4

Container {
    id: task
    
    property int taskId: 1
    property bool expanded: true
    property bool expandable: true
    property bool important: false
    property bool closed: false
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
        if (task.closed) {
            return "<html><span style=\"text-decoration: line-through;\">" + task.name +"</span></html>";
        }
        return task.name;
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
            
            horizontalAlignment: HorizontalAlignment.Fill
            layout: DockLayout {}
            
            Container {
                horizontalAlignment: HorizontalAlignment.Left
                background: selected ? ui.palette.plainBase : ui.palette.background
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container {
                    visible: task.expandable
                    verticalAlignment: VerticalAlignment.Center
                    
                    leftPadding: ui.du(1)
                    topPadding: ui.du(1)
                    bottomPadding: ui.du(1)
                    
                    ImageView {
                        imageSource: task.expanded ? "asset:///images/ic_minus.png" : "asset:///images/ic_plus.png"
                        maxWidth: ui.du(2.5)
                        maxHeight: ui.du(2.5)
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
                    maxWidth: ui.du(37)
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        opacity: task.closed ? 0.5 : 1.0
                        text: getTaskName();
                        textFormat: TextFormat.Html
                        textStyle.base: SystemDefaults.TextStyles.BodyText
                        verticalAlignment: VerticalAlignment.Center
                        multiline: true
                    }
                }
                
                Container {
                    visible: task.important
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        text: "!"
                        textStyle {
                            base: SystemDefaults.TextStyles.TitleText
                            fontWeight: FontWeight.Bold
                            color: Color.create("#FF3333")
                        }
                    }
                }
            }
            
            
            Container {
                horizontalAlignment: HorizontalAlignment.Right
                rightPadding: rememberId === "" ? ui.du(2.5) : ui.du(0)
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container {
                    visible: task.deadline !== 0
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        id: deadlineLabel
                        text: ""
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
                    
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                console.debug('checked');
                                task.closed = !task.closed;
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
        }
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
    
    onParentIdChanged: {
        divider.visible = parentId === "";
    }
    
    onDeadlineChanged: {
        deadlineLabel.text = Qt.formatDateTime(new Date(task.deadline * 1000), "dd.MM.yyyy HH:mm");
    }
    
    onCreationCompleted: {
        _tasksService.activeTaskChanged.connect(task.select);
        _tasksService.taskUpdated.connect(task.updateTask);
        _tasksService.allTasksExpanded.connect(task.expand);
        _tasksService.allTasksUnexpanded.connect(task.unexpand);
    }
    
    onClosedChanged: {
        _tasksService.changeClosed(task.taskId, task.closed);
    }
}
