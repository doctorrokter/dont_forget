import bb.cascades 1.4

Container {
    id: root
    
    property int taskId: 0
    
    visible: _tasksService.moveMode
    
    background: ui.palette.background
    
    horizontalAlignment: HorizontalAlignment.Fill
    maxHeight: ui.du(10)
    
    layout: DockLayout {}
    
    leftPadding: ui.du(1)
    topPadding: ui.du(1)
    rightPadding: ui.du(1)
    bottomPadding: ui.du(1)
    
    Button {
        horizontalAlignment: HorizontalAlignment.Left
        verticalAlignment: VerticalAlignment.Center
        text: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
        maxWidth: ui.du(17)
        
        onClicked: {
            _tasksService.deselectAll();
            _tasksService.moveMode = false;
        }
    }
    
    Label {
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        text: (qsTr("Selected") + Retranslate.onLocaleOrLanguageChanged) + ": " + _tasksService.selectedTasksCount
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    Button {
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Center
        text: "Ok"
        maxWidth: ui.du(17)
        
        onClicked: {
            _tasksService.moveBulk(root.taskId);
            _tasksService.moveMode = false;
        }
    }
}