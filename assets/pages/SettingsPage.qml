import bb.cascades 1.4
import bb.system 1.2
import bb.multimedia 1.4
import "../components"

Page {
    id: root
    
    signal sortByChanged();
    signal defaultTaskTypeChanged();
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    titleBar: CustomTitleBar {
        title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged
    }
    
    ScrollView {
        scrollRole: ScrollRole.Main
        
        Container {
            layout: DockLayout {}
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                Header {
                    title: qsTr("Look and Feel") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Dark theme") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    ToggleButton {
                        id: themeToggle
                        horizontalAlignment: HorizontalAlignment.Right
                        
                        onCheckedChanged: {
                            if (checked) {
                                Application.themeSupport.setVisualStyle(VisualStyle.Dark);
                                _appConfig.set("theme", "DARK");
                            } else {
                                Application.themeSupport.setVisualStyle(VisualStyle.Bright);
                                _appConfig.set("theme", "BRIGHT");
                            }
                        }
                    }
                }
                
                Header {
                    title: qsTr("Behavior") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(0.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Don't ask before deleting") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    ToggleButton {
                        id: dontAskBeforeDeletingToggle
                        horizontalAlignment: HorizontalAlignment.Right
                        
                        onCheckedChanged: {
                            if (checked) {
                                _appConfig.set("do_not_ask_before_deleting", "true");
                            } else {
                                _appConfig.set("do_not_ask_before_deleting", "false");
                            }
                        }
                    }
                }  
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    DropDown {
                        title: qsTr("Sort by") + Retranslate.onLocaleOrLanguageChanged
                        
                        options: [
                            Option {
                                id: sortByNameOption
                                text: qsTr("Name") + Retranslate.onLocaleOrLanguageChanged
                                value: "name"
                            },
                            
                            Option {
                                id: sortByCreationOption
                                text: qsTr("Creation") + Retranslate.onLocaleOrLanguageChanged
                                value: "id"
                            }
                        ]
                        
                        onSelectedOptionChanged: {
                            _appConfig.set("sort_by", selectedOption.value);
                            root.sortByChanged();
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    bottomPadding: ui.du(2.5)
                    DropDown {
                        title: qsTr("Default task type") + Retranslate.onLocaleOrLanguageChanged
                        
                        options: [
                            Option {
                                id: folderOption
                                text: qsTr("Folder") + Retranslate.onLocaleOrLanguageChanged
                                value: "FOLDER"
                            },
                            
                            Option {
                                id: taskOption
                                text: qsTr("Task") + Retranslate.onLocaleOrLanguageChanged
                                value: "TASK"
                            }
                        ]
                        
                        onSelectedOptionChanged: {
                            _appConfig.set("default_task_type", selectedOption.value);
                            root.defaultTaskTypeChanged();
                        }
                    }
                }
                
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(0.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("System sound on selection") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    ToggleButton {
                        id: soundOnSelect
                        horizontalAlignment: HorizontalAlignment.Right
                        
                        onCheckedChanged: {
                            if (checked) {
                                _appConfig.set("sound_on_select", "true");
                                _signal.setSoundEnabled(true);
                            } else {
                                _appConfig.set("sound_on_select", "false");
                                _signal.setSoundEnabled(false);
                            }
                        }
                    }
                }  
            
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(0.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Vibrate on selection") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    ToggleButton {
                        id: vibrateOnSelect
                        horizontalAlignment: HorizontalAlignment.Right
                        
                        onCheckedChanged: {
                            if (checked) {
                                _appConfig.set("vibrate_on_select", "true");
                                _signal.setVibrationEnabled(true);
                            } else {
                                _appConfig.set("vibrate_on_select", "false");
                                _signal.setVibrationEnabled(false);
                            }
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    DropDown {
                        title: qsTr("Notification sound") + Retranslate.onLocaleOrLanguageChanged
                        
                        options: [
                            Option {
                                id: standardTheme
                                text: qsTr("Standard Theme") + Retranslate.onLocaleOrLanguageChanged
                                value: "standard_theme"
                                selected: {
                                    var theme = _appConfig.get("notification_theme");
                                    return theme === "" || theme === standardTheme.value;
                                }
                            },
                            
                            Option {
                                id: chachkouskiTheme
                                text: qsTr("Don't Forget Theme") + Retranslate.onLocaleOrLanguageChanged
                                value: "chachkouski_theme"
                                selected: {
                                    var theme = _appConfig.get("notification_theme");
                                    return theme === chachkouskiTheme.value;
                                }
                            }
                        ]
                        
                        onSelectedOptionChanged: {
                            _appConfig.set("notification_theme", selectedOption.value);
                            if (selectedOption.value === standardTheme.value) {
                                systemSound.play();
                            } else {
                                mediaPlayer.play();
                            }
                        }
                    }
                    
                    attachedObjects: [
                        SystemSound {
                            id: systemSound
                            sound: SystemSound.GeneralNotification
                        },
                        
                        MediaPlayer {
                            id: mediaPlayer
                            volume: 1.0
                            sourceUrl: _appConfig.publicAssets + "/notification.mp3"
                        }
                    ]
                }
                
                Header {
                    title: qsTr("Network") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(0.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Receive push notifications") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    Label {
                        id: pushEnabledLabel
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Right
                        textStyle.color: Color.create("#FF3333");
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    
                    Button {
                        id: pushServiceButton
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        onClicked: {
                            if (_appConfig.hasNetwork()) {
                                loading.running = true;
                                var pushEnabled = _appConfig.get("push_service_registered");
                                if (pushEnabled === "true") {
                                    _pushService.destroyPushService();
                                } else {
                                    _appConfig.set("push_service_registered", "registration_request");
                                    _pushService.initPushService();
                                }
                            } else {
                                systemToast.body = qsTr("Check your network connection") + Retranslate.onLocaleOrLanguageChanged
                                systemToast.show();
                            }
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(0.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    
                    Label {
                        horizontalAlignment: HorizontalAlignment.Fill
                        multiline: true
                        textStyle.fontWeight: FontWeight.W100
                        text: qsTr("If this setting is turned on you can send/receive tasks to/from your colleague or someone else using PIN. " +
                        "To achieve this goal app uses BlackBerry Push Service") + Retranslate.onLocaleOrLanguageChanged
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    minHeight: ui.du(20)
                }
            }
            
            ActivityIndicator {
                id: loading
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                minWidth: ui.du(10)
            }
        }
        
        attachedObjects: [
            SystemToast {
                id: systemToast
            }
        ]
    }
    
    function adjustTheme() {
        var theme = _appConfig.get("theme");
        themeToggle.checked = theme && theme === "DARK";
    }
    
    function adjustAskBeforeDeleting() {
        var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
        dontAskBeforeDeletingToggle.checked = doNotAsk && doNotAsk === "true";
    }
    
    function adjustSoundOnSelect() {
        var sound = _appConfig.get("sound_on_select");
        soundOnSelect.checked = sound && sound === "true";
    }
    
    function adjustVibrationOnSelect() {
        var vibro = _appConfig.get("vibrate_on_select");
        vibrateOnSelect.checked = vibro && vibro === "true";
    }
    
    function adjustSortBy() {
        var sortBy = _appConfig.get("sort_by");
        sortByNameOption.selected = sortBy === "" || sortBy === "name";
        sortByCreationOption.selected = sortBy === "id";
    }
    
    function adjustDefaultTaskType() {
        var defaultTaskType = _appConfig.get("default_task_type");
        folderOption.selected = defaultTaskType === "FOLDER";
        taskOption.selected = defaultTaskType === "" || defaultTaskType === "TASK";
    }
    
    function adjustNotificationTheme() {
        var theme = _appConfig.get("notification_theme");
        standardTheme.selected = theme === "standard_theme" || theme === "";
        chachkouskiTheme.selected = theme === "chachkouski_theme";
    }
    
    function adjustPushEnabledLabel() {
        var pushEnabled = _appConfig.get("push_service_registered");
        if (pushEnabled === "true") {
            pushEnabledLabel.text = qsTr("Enabled") + Retranslate.onLocaleOrLanguageChanged;
        } else {
            pushEnabledLabel.text = qsTr("Disabled") + Retranslate.onLocaleOrLanguageChanged;
        }
    }
    
    function adjustPushServiceButton() {
        var pushEnabled = _appConfig.get("push_service_registered");
        if (pushEnabled === "true") {
            pushServiceButton.text = qsTr("Disable") + Retranslate.onLocaleOrLanguageChanged;
        } else {
            pushServiceButton.text = qsTr("Enable") + Retranslate.onLocaleOrLanguageChanged;
        }
    }
    
    function pushRegistered() {
        _appConfig.set("push_service_registered", "true");
        loading.running = false;
        systemToast.body = qsTr("Push Service enabled") + Retranslate.onLocaleOrLanguageChanged;
        systemToast.show();
        adjustPushEnabledLabel();
        adjustPushServiceButton();
    }
    
    function pushUnregistered() {
        _appConfig.set("push_service_registered", "false");
        loading.running = false;
        systemToast.body = qsTr("Push Service disabled") + Retranslate.onLocaleOrLanguageChanged;
        systemToast.show();
        adjustPushEnabledLabel();
        adjustPushServiceButton();
    }
    
    function pushFailed() {
        loading.running = false;
        enabledPushToggle.checked = !enabledPushToggle.checked;
        systemToast.body = qsTr("Failed to enable Push Service") + Retranslate.onLocaleOrLanguageChanged;
        systemToast.show();
    }
    
    function clear() {
        _pushService.channelCreated.disconnect(root.pushRegistered);
        _pushService.channelDestroyed.disconnect(root.pushUnregistered);
        _pushService.channelCreationFailed.disconnect(root.pushFailed);
    }
    
    onCreationCompleted: {
        adjustTheme();
        adjustAskBeforeDeleting();
        adjustSortBy();
        adjustDefaultTaskType();
        adjustPushEnabledLabel();
        adjustPushServiceButton();
        adjustSoundOnSelect();
        adjustVibrationOnSelect();
//        adjustNotificationTheme();
        _pushService.channelCreated.connect(root.pushRegistered);
        _pushService.channelDestroyed.connect(root.pushUnregistered);
        _pushService.channelCreationFailed.connect(root.pushFailed);
    }
}