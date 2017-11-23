import bb.cascades 1.4
import bb.device 1.4
import "../components"
import "../components/v2"

Page {
    id: root
    
    property int screenWidth: 1440
    property int screenHeight: 1440
    
    property variant steps: {
        INDEX: "index",
        TABS: "tabs",
        ACTIVE_FRAMES: "active_frames",
        EXPANDABLE: "expandable",
        DELETING: "deleting",
        WALLPAPERS: "wallpapers"
    }
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layout: DockLayout {}
        
        background: Color.White
        
        ListView {
            id: listView
            
            property double width: 0
            property double height: 0
            
            dataModel: ArrayDataModel {
                id: dataModel
            }
            
            layout: StackListLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            flickMode: FlickMode.SingleItem
            
            function itemType(data, indexPath) {
                return data.step;
            }
            
            listItemComponents: [
                ListItemComponent {
                    type: root.steps.ACTIVE_FRAMES    
                    OnboardingListItem {
                        color: "#F0F0F0"
                        title: qsTr("Active frames") + Retranslate.onLocaleOrLanguageChanged
                        description: qsTr("When app is backgrounded it will show today tasks in active frame.") + Retranslate.onLocaleOrLanguageChanged
                        imageSource: "asset:///images/screenshots/active_frames.png"
                        textColor: ui.palette.textOnPlain
                    }
                },
                
                ListItemComponent {
                    type: root.steps.EXPANDABLE    
                    OnboardingListItem {
                        color: "#323232"
                        title: qsTr("Quick view") + Retranslate.onLocaleOrLanguageChanged
                        description: qsTr("Double tap by task will expand the content with all attachments, description etc.") + Retranslate.onLocaleOrLanguageChanged
                        imageSource: "asset:///images/screenshots/expandable.png"
                        textColor: ui.palette.textOnPrimary
                    }
                },
                
                ListItemComponent {
                    type: root.steps.WALLPAPERS    
                    OnboardingListItem {
                        color: "#779933"
                        title: qsTr("Wallpapers") + Retranslate.onLocaleOrLanguageChanged
                        description: qsTr("You can set a wallpaper through the Settings page.") + Retranslate.onLocaleOrLanguageChanged
                        imageSource: "asset:///images/screenshots/wallpapers.png"
                        textColor: ui.palette.textOnPlain
                        last: true
                    }
                },
                
                ListItemComponent {
                    type: root.steps.DELETING    
                    OnboardingListItem {
                        color: "#DCD427"
                        title: qsTr("Advanced removing") + Retranslate.onLocaleOrLanguageChanged
                        description: qsTr("In addition, now you can delete task simply by swiping left.") + Retranslate.onLocaleOrLanguageChanged
                        imageSource: "asset:///images/screenshots/removing.png"
                        textColor: ui.palette.textOnPlain
                    }
                },
                
                ListItemComponent {
                    type: root.steps.TABS    
                    OnboardingListItem {
                        color: "##CC3333"
                        title: qsTr("Tabs") + Retranslate.onLocaleOrLanguageChanged
                        description: qsTr("Now on main screen you have several tabs for quick access to most useful filters.") + Retranslate.onLocaleOrLanguageChanged
                        imageSource: "asset:///images/screenshots/tabs.png"
                        textColor: ui.palette.textOnPrimary
                    }
                },
                
                ListItemComponent {
                    type: root.steps.INDEX
                    CustomListItem {
                        highlightAppearance: HighlightAppearance.None
                        
                        preferredWidth: ListItem.view.width
                        preferredHeight: ListItem.view.height
                        
                        Container {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: ui.palette.primaryBase
                            
                            layout: DockLayout {}
                            
                            ColorContainer {
                                color: "#087099" // storm blue
                            }
                            
                            Container {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                
                                ImageView {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    imageSource: "asset:///images/logo.png"
                                    minHeight: ui.du(15)
                                    minWidth: ui.du(30)
                                }
                                
                                Label {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    text: qsTr("Let's check what's new in Don't Forget 2.0!") + Retranslate.onLocaleOrLanguageChanged
                                    multiline: true
                                    textStyle.color: ui.palette.textOnPrimary
                                }
                            }
                            
                            SwipeContainer {
                                textColor: ui.palette.textOnPrimary
                            }
                        }
                    }
                }
            ]
            
            attachedObjects: [
                LayoutUpdateHandler {
                    id: rootLUH
                    
                    onLayoutFrameChanged: {
                        listView.width = layoutFrame.width;
                        listView.height = layoutFrame.height;
                    }
                }
            ]
        }    
        
    }
    
    onCreationCompleted: {
        var data = [];
        data.push({step: root.steps.INDEX});
        data.push({step: root.steps.TABS});
        data.push({step: root.steps.ACTIVE_FRAMES});
        data.push({step: root.steps.EXPANDABLE});
        data.push({step: root.steps.DELETING});
        data.push({step: root.steps.WALLPAPERS});
        dataModel.append(data);
    }
}
