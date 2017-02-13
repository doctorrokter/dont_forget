import bb.cascades 1.4
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
                        "when task's deadline is coming you should do the following:<br/>1. Click by <strong>Create</strong> button.<br/>" + 
                        "2. Set <strong>Deadline</strong>.<br/>3. Set <strong>Create in Remember</strong>.") + Retranslate.onLocaleOrLanguageChanged
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
                        text: qsTr("<strong>Tap gestures</strong><br/>1. <strong>Single tap</strong> by task's label in a tasks tree will select this task and mark as " + 
                                   "<strong>active</strong>. Task will become highlighted.<br/>2. <strong>Double tap</strong> by task's label will open task's details sheet.<br/>" + 
                                   "3. If task is expandable (has children or has type Folder)" + 
                                   " you can expand or narrow task by clicking - or + button near task's icon.") + Retranslate.onLocaleOrLanguageChanged
                        textFormat: TextFormat.Html
                        multiline: true
                    }
                }
                
                Container {
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    bottomPadding: ui.du(2.5)
                    
                    Label {
                        text: qsTr("<strong>Pinch gestures</strong><br/>In order to expand or narrow all tasks in a tree you can use pinch gesture.") + Retranslate.onLocaleOrLanguageChanged
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
                        "in a <strong>Name</strong> field during task creation.<br/><br/>Example:<br/>1. Click by <strong>Create</strong> button.<br/>" + 
                        "2. In a <strong>Name</strong> field type something like <strong>task1;;task2;;task3</strong> and click <strong>Save</strong> button.<br/>" + 
                        "3. Result: three separate tasks will be created in a tasks tree.") + Retranslate.onLocaleOrLanguageChanged
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
}
