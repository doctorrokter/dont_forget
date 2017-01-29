import bb.cascades 1.4

Container {
    id: root
    
    property string title: "test"
    property bool checked: false
    
    horizontalAlignment: HorizontalAlignment.Fill
    
    Container {
        leftPadding: ui.du(2.5)
        topPadding: ui.du(2.5)
        rightPadding: ui.du(2.5)
        horizontalAlignment: HorizontalAlignment.Fill
        
        layout: DockLayout {}
        
        Container {
            horizontalAlignment: HorizontalAlignment.Left
            verticalAlignment: VerticalAlignment.Center
            Label {
                text: root.title
            }
        }
        
        Container {
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: VerticalAlignment.Center
            ToggleButton {
                id: toggleButton
                checked: root.checked
                
                onCheckedChanged: {
                    root.checked = checked;
                }
            }
        }
    }
    Divider {}
}
