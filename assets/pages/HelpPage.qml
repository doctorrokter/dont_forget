import bb.cascades 1.4
import bb.system 1.2
import bb.platform 1.3
import "../components"

Page {
    id: root
    
    titleBar: CustomTitleBar {
        title: qsTr("Help/Tutorial Center") + Retranslate.onLocaleOrLanguageChanged
    }
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            
            Container {
                Header {
                    title: qsTr("Common") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    Label {
                        text: qsTr("Author: ") + Retranslate.onLocaleOrLanguageChanged
                    }
                    
                    Label {
                        text: "Mikhail Chachkouski"
                        textStyle.color: ui.palette.primary
                        textStyle.fontWeight: FontWeight.W500
                        
                        gestureHandlers: [
                            TapHandler {
                                onTapped: {
                                    bbwInvoke.trigger(bbwInvoke.query.invokeActionId);
                                }
                            }
                        ]
                    }
                }
                
                Container {
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    bottomPadding: ui.du(2.5)
                    
                    Label {
                        text: qsTr("App name: ") + Retranslate.onLocaleOrLanguageChanged + Application.applicationName
                    }
                    
                    Label {
                        text: qsTr("App version: ") + Retranslate.onLocaleOrLanguageChanged + Application.applicationVersion
                    }
                    
                    Label {
                        text: qsTr("OS version: ") + Retranslate.onLocaleOrLanguageChanged + platform.osVersion
                    }
                }
            }
            
            
            Container {
                Header {
                    title: qsTr("Reminders") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    bottomPadding: ui.du(2.5)
                    
                    Label {
                        text: qsTr("Don't Forget app <strong>does not provide</strong> own reminder mechanism. " + 
                        "Instead of it, app uses Remember as reminder mechanism.<br/><br/>In order to get notified " + 
                        "when task's deadline is coming you should do the following:<br/>1. Create a <strong>Task</strong> or a <strong>List</strong>.<br/>" + 
                        "2. Open edit mode.<br/>3. Set <strong>Deadline</strong>.<br/>4. Set <strong>Create in Remember</strong>.") + Retranslate.onLocaleOrLanguageChanged
                        textFormat: TextFormat.Html
                        multiline: true
                    }
                }
            }
            
            Container {
                Header {
                    title: qsTr("Gestures") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    bottomPadding: ui.du(2.5)
                    
                    Label {
                        text: qsTr("1. <strong>Double tap</strong> by task will expand task's content with all attachments, description etc without leaving the current page.<br/>" + 
                                   "2. <strong>Swipe left</strong> on the task will delete it.") + Retranslate.onLocaleOrLanguageChanged
                        textFormat: TextFormat.Html
                        multiline: true
                    }
                }
            }
            
            Container {
                Header {
                    title: qsTr("Bulk creation") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    
                    Label {
                        text: qsTr("In order to create several tasks per one action you can use a special delimeter <strong>;;</strong> " +  
                        "in a <strong>Name</strong> field during task creation.<br/><br/>Example:<br/>1. Click by <strong>Create Task</strong> button.<br/>" + 
                        "2. In an input field type something like <strong>task1;;task2;;task3</strong> and click <strong>Ok</strong> button.<br/>" + 
                        "3. Result: three separate tasks will be created in current folder or list.") + Retranslate.onLocaleOrLanguageChanged
                        multiline: true
                        textFormat: TextFormat.Html
                    }
                }
            }
            
            Container {
                minHeight: ui.du(20)
            }
        }
    }
    
    attachedObjects: [
        Invocation {
            id: bbwInvoke
            query {
                uri: "appworld://vendor/97424"
                invokeActionId: "bb.action.OPEN"
                invokeTargetId: "sys.appworld"
            }
        },
        
        PlatformInfo {
            id: platform
        }
    ]
}
