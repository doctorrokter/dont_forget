import bb.cascades 1.4

TitleBar {
    id: root
    
    property ActionItem cancelAction
    property ActionItem submitAction
    property bool clearable: false
    property string imageSource: ""
    
    appearance: TitleBarAppearance.Plain
    kind: TitleBarKind.FreeForm
    
    kindProperties: FreeFormTitleBarKindProperties {
        Container {
            background: Application.themeSupport.theme.colorTheme.primaryBase
            leftPadding: ui.du(2)
            rightPadding: ui.du(2)
            layout: DockLayout {}
            
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
                id: imageContainer
                visible: root.imageSource !== ""
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                
                ImageView {
                    imageSource: root.imageSource
                    maxWidth: ui.du(6)
                    maxHeight: ui.du(6)
                }
            }
            
            Container {
                horizontalAlignment: {
                    if (root.cancelAction) {
                        return HorizontalAlignment.Center;
                    }
                    return HorizontalAlignment.Left;
                }
                verticalAlignment: VerticalAlignment.Center
                margin.leftOffset: {
                    if (imageContainer.visible) {
                        return ui.du(8);
                    }
                    return 0;
                }
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
                minWidth: ui.du(12)
                
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
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    leftPadding: ui.du(1)
                    topPadding: ui.du(2.5)
                    rightPadding: ui.du(1)
                    bottomPadding: ui.du(2.5)
                    
                    maxWidth: ui.du(15)
                    minWidth: ui.du(15)
                    
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
