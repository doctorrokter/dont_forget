import bb.cascades 1.4

TitleBar {
    id: root
    
    property ActionItem cancelAction
    property ActionItem submitAction
    property bool clearable: false
    
    appearance: TitleBarAppearance.Plain
    kind: TitleBarKind.FreeForm
    
    kindProperties: FreeFormTitleBarKindProperties {
        Container {
            background: Application.themeSupport.theme.colorTheme.primaryBase
            leftPadding: ui.du(2)
            rightPadding: ui.du(2)
            layout: DockLayout {}
            
            Container {
                visible: root.clearable
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                ImageView {
                    imageSource: "asset:///images/ic_deselect.png"
                    maxWidth: ui.du(7)
                    maxHeight: ui.du(7)
                }
                
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            _tasksService.setActiveTask(0);
                        }
                    }
                ]
            }
            
            Container {
                id: cancelContainer
                visible: false
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container {
                    id: cancelContainerButton
                    
                    leftPadding: ui.du(1)
                    topPadding: ui.du(2.5)
                    rightPadding: ui.du(1)
                    bottomPadding: ui.du(2.5)
                    
                    Label {
                        id: cancelContainerText
                        textStyle.color: ui.palette.textOnPrimary
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                    
                    onTouch: {
                        if (event.isDown()) {
                            cancelContainerButton.opacity = 0.5;
                        }
                        if (event.isUp()) {
                            cancelContainerButton.opacity = 1.0;
                        }
                    }
                    
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                root.cancelAction.triggered();
                            }
                        }
                    ]
                }
                
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    preferredWidth: ui.du(0.2)
                    preferredHeight: ui.du(7)
                    background:  ui.palette.textOnPrimary
                }
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                maxWidth: ui.du(40)
                Label {
                    text: title
                    textStyle.base: SystemDefaults.TextStyles.TitleText
                    textStyle.color: ui.palette.textOnPrimary
                }
            }
            
            Container {
                id: submitContainer
                visible: false
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    preferredWidth: ui.du(0.2)
                    preferredHeight: ui.du(7)
                    background:  ui.palette.textOnPrimary
                }
                
                Container {
                    id: submitContainerButton
                    
                    leftPadding: ui.du(1)
                    topPadding: ui.du(2.5)
                    rightPadding: ui.du(1)
                    bottomPadding: ui.du(2.5)
                    
                    maxWidth: ui.du(15)
                    
                    Label {
                        id: submitContainerText
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.color: ui.palette.textOnPrimary
                    }
                    
                    onTouch: {
                        if (event.isDown()) {
                            submitContainerButton.opacity = 0.5;
                        }
                        if (event.isUp()) {
                            submitContainerButton.opacity = 1.0;
                        }
                    }
                    
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                root.submitAction.triggered();
                            }
                        }
                    ]
                }
            }
        }
    }
    
    onCreationCompleted: {
        if (root.cancelAction) {
            cancelContainer.visible = true;
            cancelContainerText.text = root.cancelAction.title;
        }
        
        if (root.submitAction) {
            submitContainer.visible = true;
            submitContainerText.text = root.submitAction.title;
        }
    }
}
