import bb.cascades 1.4
import bb.system 1.2
import "../components"
import "../sheets"

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
            
            dataModel: GroupDataModel {
                id: contactsDataModel
                grouping: ItemGrouping.ByFirstChar
                sortingKeys: ["first_name", "last_name"]
            }
            
            listItemComponents: [
                ListItemComponent {
                    type: "item"
                    StandardListItem {
                        title: ListItemData.first_name + " " + ListItemData.last_name
                        description: ListItemData.pin
                        
                        contextActions: [
                            ActionSet {
                                DeleteActionItem {
                                    onTriggered: {
                                        _usersService.remove(ListItemData.id);
                                    }
                                }
                                
                                ActionItem {
                                    title: qsTr("Edit") + Retranslate.onLocaleOrLanguageChanged
                                    imageSource: "asset:///images/ic_compose.png"
                                    
                                    onTriggered: {
                                        _usersService.requestUser(ListItemData.id);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
            
            onTriggered: {
                if (_appConfig.hasNetwork()) {
                    var data = contactsDataModel.data(indexPath);
                    if (_tasksService.activeTask !== null) {
                        loading.running = true;
                        
                        var collectSiblings = function(rootTask) {
                            rootTask.children = _tasksService.findSiblings(rootTask.id);
                            rootTask.attachments = _attachmentsService.getEncodedAttachments(rootTask.id);
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
                            
                            var xhr = new XMLHttpRequest();
                            xhr.open("POST", "https://bb10-push-sender.herokuapp.com/push", true);
                            xhr.setRequestHeader("Content-type", "application/json");
                            xhr.onreadystatechange = function() {
                                if (xhr.readyState == 4) {
                                    loading.running = false;
                                    
                                    var responseStr = xhr.responseText;
                                    console.debug(responseStr);
                                    
                                    var response = JSON.parse(responseStr);
                                    var statusCode = parseInt(response.message.statusCode);
                                    if (statusCode === 1001) {
                                        if (rootTask.children.length !== 0) {
                                            toast.body = qsTr("Tasks sent!") + Retranslate.onLocaleOrLanguageChanged;
                                        } else {
                                            toast.body = qsTr("Task sent!") + Retranslate.onLocaleOrLanguageChanged;
                                        }
                                        toast.show();
                                        tasksSent();
                                    } else if (statusCode === 4001) {
                                        toast.body = qsTr("The BlackBerry Push Server is busy, try again later.") + Retranslate.onLocaleOrLanguageChanged;
                                        toast.show();
                                    }
                                } else {
                                    loading.running = false;
                                    console.debug(xhr.responseText);
                                    toast.body = qsTr("Something went wrong with sending push notification...") + Retranslate.onLocaleOrLanguageChanged;
                                    toast.show();
                                }
                            }
                            var params = JSON.stringify({pins: [PIN], message: {body: JSON.parse(data)}});
                            xhr.send(params);
                        };
                        
                        _dropboxService.uploadFile(PIN + "_" + new Date().getTime() + ".json", JSON.stringify(rootTask));
                        _dropboxService.tempLinkCreated.connect(processTempLink);
                    }
                } else {
                    toast.body = qsTr("Check your network connection") + Retranslate.onLocaleOrLanguageChanged;
                    toast.show();                   
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
            
            onTriggered: {
                contactSheet.open();
            }
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
                contactsDataModel.insertList(filteredUsers);
            }
        },
        
        AddContactSheet {
            id: contactSheet
        },
        
        SystemToast {
            id: toast
        }
    ]
    
    function addUser(user) {
        contactsDataModel.insert(user);
    }
    
    function fill() {
        root.users = _usersService.findAll();
        contactsDataModel.clear();
        contactsDataModel.insertList(root.users);
    }
    
    function showActiveUser(user) {
        contactSheet.userId = user.id;
        contactSheet.firstName = user.first_name;
        contactSheet.lastName = user.last_name;
        contactSheet.pin = user.pin;
        contactSheet.mode = "UPDATE";
        contactSheet.open();
    }
    
    function clear() {
        _usersService.userAdded.disconnect(root.addUser);
        _usersService.userRemoved.disconnect(root.fill);
        _usersService.userUpdated.disconnect(root.fill);
        _usersService.requestedUserDone.disconnect(root.showActiveUser);
    }
    
    onCreationCompleted: {
        fill();
        _usersService.userAdded.connect(root.addUser);
        _usersService.userRemoved.connect(root.fill);
        _usersService.userUpdated.connect(root.fill);
        _usersService.requestedUserDone.connect(root.showActiveUser);
    }
    
    onSearchModeChanged: {
        if (root.searchMode) {
            root.titleBar = inputTitleBar;
            root.titleBar.focus();
        } else {
            root.titleBar.reset();
            root.titleBar = defaultTitleBar;
            fill();
        }
    }
}
