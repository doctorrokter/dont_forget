import bb.cascades 1.4

Dialog {
    id: root
    
    signal confirm();
    signal cancel();
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.create(0.0, 0.0, 0.0, 0.5)
        layout: DockLayout {}
        
        Container {
            id: mainContainer
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            maxHeight: ui.du(70)
            maxWidth: ui.du(70);
            background: ui.palette.background
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: ui.du(2.5)
                leftPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
                
                Label {
                    text: qsTr("Confirm the deleting") + Retranslate.onLocaleOrLanguageChanged
                    textStyle.base: SystemDefaults.TextStyles.TitleText
                }
                
                Divider {}
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: ui.du(2.5)
                leftPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
                
                Label {
                    text: qsTr("This action cannot be undone. Also, task may contain children. All these will be deleted. Continue?") + Retranslate.onLocaleOrLanguageChanged
                    textStyle.base: SystemDefaults.TextStyles.BodyText
                    multiline: true
                }
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: ui.du(2.5)
                leftPadding: ui.du(2.5)
                rightPadding: ui.du(2.5)
                bottomPadding: ui.du(2.5)
                
                CheckBox {
                    text: qsTr("Don't ask again") + Retranslate.onLocaleOrLanguageChanged
                    
                    onCheckedChanged: {
                        _appConfig.set("do_not_ask_before_deleting", checked);
                    }
                }
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Button {
                    text: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                    
                    onClicked: {
                        root.cancel();
                        root.close();
                    }
                }
                
                Button {
                    text: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
                    
                    onClicked: {
                        root.confirm();
                        root.close();
                    }
                }
            }
        }
    }
}