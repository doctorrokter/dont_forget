import bb.cascades 1.4
import "../components"

Page {
    id: root
    
    property bool searchMode: false
    property variant users: []
    
    signal tasksSent()
    
    titleBar: defaultTitleBar
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layout: DockLayout {}
        
        ListView {
            id: contactsList
            
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: contactsDataModel
            }
            
            listItemComponents: [
                ListItemComponent {
                    StandardListItem {
                        title: ListItemData.first_name + " " + ListItemData.last_name
                        description: ListItemData.pin
                    }
                }
            ]
            
            onTriggered: {
                var data = contactsDataModel.data(indexPath);
                if (_tasksService.activeTask !== null) {
                    loading.running = true;
                    
                    var collectSiblings = function(rootTask) {
                        rootTask.children = _tasksService.findSiblings(rootTask.id);
                        if (rootTask.children.length !== 0) {
                            rootTask.children.forEach(function(sibling) {
                                    collectSiblings(sibling);
                            });
                        }
                    };
                    
                    var rootTask = _tasksService.activeTask.toJson();
                    collectSiblings(rootTask);
                    
                    var PIN = data.pin;
                    var processTempLink = function(data) {
                        _dropboxService.tempLinkCreated.disconnect(processTempLink);
                        _pushService.pushMessageToUser(PIN, 2, "Tasks", data);
                        if (rootTask.children.length !== 0) {
                            toast.body = qsTr("Tasks sent!") + Retranslate.onLocaleOrLanguageChanged;
                        } else {
                            toast.body = qsTr("Task sent!") + Retranslate.onLocaleOrLanguageChanged;
                        }
                        loading.running = false;
                        toast.show();
                        tasksSent();
                    };
                    
                    _dropboxService.uploadFile(PIN + "_" + new Date().getTime() + ".json", JSON.stringify(rootTask));
                    _dropboxService.tempLinkCreated.connect(processTempLink);
                }
            }
        }
        
        ActivityIndicator {
            id: loading
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            running: false
            minWidth: ui.du(10)
        }
    }
    
    actions: [
        ActionItem {
            title: qsTr("Add") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_add.png"
            ActionBar.placement: ActionBarPlacement.Signature
        },
        
        ActionItem {
            title: qsTr("Search") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_search.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                root.searchMode = true;
            }
        }
    ]
    
    attachedObjects: [
        CustomTitleBar {
            id: defaultTitleBar
            title: qsTr("Users") + Retranslate.onLocaleOrLanguageChanged
        },
        
        InputTitleBar {
            id: inputTitleBar
            
            onCancel: {
                root.searchMode = false;
            }
            
            onTyping: {
                var filteredUsers = users.filter(function(u) {
                    return u.first_name.toLowerCase().indexOf(text.toLowerCase()) !== -1 ||
                           u.last_name.toLowerCase().indexOf(text.toLowerCase()) !== -1 ||
                           u.pin.toLowerCase().indexOf(text.toLowerCase()) !== -1;
                });
                contactsDataModel.clear();
                contactsDataModel.append(filteredUsers);
            }
        }
    ]
    
    onCreationCompleted: {
        var data = [];
        data.push({first_name: "Mikhail", last_name: "Chachkouski", pin: "2BF98F81"});
        data.push({first_name: "Tatiana", last_name: "Yukhnovskaya", pin: "2BF98F81"});
        root.users = data;
        contactsDataModel.append(data);
    }
    
    onSearchModeChanged: {
        if (root.searchMode) {
            root.titleBar = inputTitleBar;
            root.titleBar.focus();
        } else {
            root.titleBar.reset();
            root.titleBar = defaultTitleBar;
            contactsDataModel.clear();
            contactsDataModel.append(users);
        }
    }
}
