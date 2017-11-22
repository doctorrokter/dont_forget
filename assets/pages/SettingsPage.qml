import bb.cascades 1.4
import bb.system 1.2
import bb.multimedia 1.4
import "../components"
import "./settings_components"

Page {
    id: root
    
    property variant settings: {
        THEME: "theme",
        BACKUP_ENABLED: "backup_enabled",
        BACKUP_EVERY: "backup_every",
        BACKUPS_NUMBER: "backups_number",
        DO_NOT_ASK_BEFORE_DELETING: "do_not_ask_before_deleting",
        DEFAULT_ACCOUNT_ID: "default_account_id",
        DEFAULT_FOLDER_ID: "default_folder_id"
    }
    
    signal backgroundPageRequested()
    
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
                                _appConfig.set(root.settings.THEME, "DARK");
                            } else {
                                Application.themeSupport.setVisualStyle(VisualStyle.Bright);
                                _appConfig.set(root.settings.THEME, "BRIGHT");
                            }
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    Button {
                        horizontalAlignment: HorizontalAlignment.Fill
                        text: qsTr("Change background") + Retranslate.onLocaleOrLanguageChanged
                        
                        onClicked: {
                            root.backgroundPageRequested();
                        }
                    }
                }
                
//                BackupAndRecovery {
//                    id: backupAndRecoverySection
//                }
                
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
                                _appConfig.set(root.settings.DO_NOT_ASK_BEFORE_DELETING, "true");
                            } else {
                                _appConfig.set(root.settings.DO_NOT_ASK_BEFORE_DELETING, "false");
                            }
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
                        id: calendarAccounts
                        title: qsTr("Default calendar account") + Retranslate.onLocaleOrLanguageChanged
                        
                        onSelectedOptionChanged: {
                            var folderId = calendarAccounts.selectedValue.folderId;
                            var accountId = calendarAccounts.selectedValue.accountId;
                            _appConfig.set(root.settings.DEFAULT_ACCOUNT_ID, accountId);
                            _appConfig.set(root.settings.DEFAULT_FOLDER_ID, folderId);
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
                        title: qsTr("Date/time format") + Retranslate.onLocaleOrLanguageChanged
                        
                        options: [
                            Option {
                                id: customFormatOption
                                text: "dd.MM.yyyy, hh:mm"
                                value: "dd.MM.yyyy, hh:mm"
                            },
                            
                            Option {
                                id: customFormatOption2
                                text: "ddd dd, MMM yyyy, hh:mm"
                                value: "ddd dd, MMM yyyy, hh:mm"
                            },
                            
                            Option {
                                id: customFormatOption3
                                text: "MMM dd, hh:mm"
                                value: "MMM dd, hh:mm"
                            },
                            
                            Option {
                                id: customFormatOption4
                                text: "MMM dd, yyyy, hh:mm"
                                value: "MMM dd, yyyy, hh:mm"
                            },
                            
                            Option {
                                id: customFormatOption5
                                text: "MMM dd, ddd yyyy, hh:mm"
                                value: "MMM dd, ddd yyyy, hh:mm"
                            },
                            
                            Option {
                                id: customFormatOption6
                                text: "MMM dd, ddd, hh:mm"
                                value: "MMM dd, ddd, hh:mm"
                            },
                            
                            Option {
                                id: localizedFormatOption
                                text: qsTr("Localized") + Retranslate.onLocaleOrLanguageChanged
                                value: "localized"
                            }
                        ]
                        
                        onSelectedOptionChanged: {
                            _appConfig.set("date_format", selectedOption.value);
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    DropDown {
                        id: soundDropDown
                        title: qsTr("Push notification sound") + Retranslate.onLocaleOrLanguageChanged
                        
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
            },
            
            ComponentDefinition {
                id: option
                Option {}
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
    
    function adjustDateTimeFormat() {
        var df = _appConfig.get("date_format");
        customFormatOption.selected = (df === "" || df === customFormatOption.value);
        customFormatOption2.selected = (df === "" || df === customFormatOption2.value);
        customFormatOption3.selected = (df === "" || df === customFormatOption3.value);
        customFormatOption4.selected = (df === "" || df === customFormatOption4.value);
        customFormatOption5.selected = (df === "" || df === customFormatOption5.value);
        customFormatOption6.selected = (df === "" || df === customFormatOption6.value);
        localizedFormatOption.selected = (df === localizedFormatOption.value);
    }
    
    function adjustCalendarAccounts() {
        var accountId = _appConfig.get("default_account_id");
        var folderId = _appConfig.get("default_folder_id");
        if (accountId === "" || folderId === "") {
            accountId = 1;
            folderId = 1;
        }
        _calendar.initFolders(calendarAccounts, folderId, accountId);
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
        soundDropDown.selectedOptionChanged.disconnect(root.playSound);
    }
    
    function playSound(selectedOption) {
        _appConfig.set("notification_theme", soundDropDown.selectedOption.value);
        if (soundDropDown.selectedOption.value === standardTheme.value) {
            systemSound.play();
        } else {
            mediaPlayer.play();
        }
    }
    
    onCreationCompleted: {
        adjustTheme();
        adjustAskBeforeDeleting();
        adjustPushEnabledLabel();
        adjustPushServiceButton();
        adjustDateTimeFormat();
        adjustNotificationTheme();
        adjustCalendarAccounts();
        _pushService.channelCreated.connect(root.pushRegistered);
        _pushService.channelDestroyed.connect(root.pushUnregistered);
        _pushService.channelCreationFailed.connect(root.pushFailed);
        soundDropDown.selectedOptionChanged.connect(root.playSound);
    }
}