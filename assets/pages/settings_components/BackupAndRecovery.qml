import bb.cascades 1.4

Container {
    id: root
    
    property variant settings: {
        BACKUP_ENABLED: "backup_enabled",
        BACKUP_EVERY: "backup_every",
        BACKUPS_NUMBER: "backups_number"
    }
    
    Header {
        title: qsTr("Backup & Recovery") + Retranslate.onLocaleOrLanguageChanged
    }
    
    Container {
        layout: DockLayout {}
        topPadding: ui.du(2)
        bottomPadding: ui.du(0.5)
        leftPadding: ui.du(2.5)
        rightPadding: ui.du(2.5)
        horizontalAlignment: HorizontalAlignment.Fill
        
        Label {
            text: qsTr("Enable backup") + Retranslate.onLocaleOrLanguageChanged
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Left
        }
        
        ToggleButton {
            id: backupEnableToggle
            horizontalAlignment: HorizontalAlignment.Right
            
            onCheckedChanged: {
                if (checked) {
                    _appConfig.set(root.settings.BACKUP_ENABLED, "true");
                    _appConfig.set(root.settings.BACKUP_EVERY, backupOptions.options[0].value);
                    _appConfig.set(root.settings.BACKUPS_NUMBER, backupsNumber.options[0].value);
                } else {
                    _appConfig.set(root.settings.BACKUP_ENABLED, "false");
                }
            }
        }
    }
    
    Container {
        visible: backupEnableToggle.checked
        topPadding: ui.du(2)
        bottomPadding: ui.du(0.5)
        leftPadding: ui.du(2.5)
        rightPadding: ui.du(2.5)
        horizontalAlignment: HorizontalAlignment.Fill
        
        DropDown {
            id: backupOptions
            title: qsTr("Backup every (days)") + Retranslate.onLocaleOrLanguageChanged
            
            onSelectedValueChanged: {
                _appConfig.set(root.settings.BACKUP_EVERY, selectedValue);
            }
            
            onCreationCompleted: {
                for (var i = 1; i < 31; i++) {
                    var opt = option.createObject(backupOptions);
                    opt.text = i;
                    opt.value = i;
                    backupOptions.add(opt);
                }
                root.adjustBackupEvery();
            }
        }
    }
    
    Container {
        visible: backupEnableToggle.checked
        topPadding: ui.du(2)
        bottomPadding: ui.du(0.5)
        leftPadding: ui.du(2.5)
        rightPadding: ui.du(2.5)
        horizontalAlignment: HorizontalAlignment.Fill
        
        DropDown {
            id: backupsNumber
            title: qsTr("Number of saved backups") + Retranslate.onLocaleOrLanguageChanged
            
            onSelectedValueChanged: {
                _appConfig.set(root.settings.BACKUPS_NUMBER, selectedValue);
            }
            
            onCreationCompleted: {
                for (var i = 1; i < 11; i++) {
                    var opt = option.createObject(backupsNumber);
                    opt.text = i;
                    opt.value = i;
                    backupsNumber.add(opt);
                }
                root.adjustBackupsNumber();
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: option
            Option {}
        }
    ]
    
    function adjustBackupEnableToggle() {
        var enabled = _appConfig.get(root.settings.BACKUP_ENABLED);
        backupEnableToggle.checked = enabled !== "" || enabled === "true";
    }
    
    function adjustBackupEvery() {
        var backupEvery = _appConfig.get(root.settings.BACKUP_EVERY);
        if (backupEvery === "") {
            backupOptions.options[0].selected = true;
        } else {
            for (var i = 0; i <= backupOptions.options.length; i++) {
                var opt = backupOptions.options[i];
                opt.selected = opt.value === parseInt(backupEvery);
                if (opt.selected) {
                    return;
                }
            }
        }
    }
    
    function adjustBackupsNumber() {
        var backupsNum = _appConfig.get(root.settings.BACKUPS_NUMBER);
        if (backupsNum === "") {
            backupsNumber.options[0].selected = true;
        } else {
            for (var i = 0; i <= backupsNumber.options.length; i++) {
                var opt = backupsNumber.options[i];
                opt.selected = opt.value === parseInt(backupsNum);
                if (opt.selected) {
                    return;
                }
            }
        }
    }
    
    onCreationCompleted: {
        adjustBackupEnableToggle();
    }
}
