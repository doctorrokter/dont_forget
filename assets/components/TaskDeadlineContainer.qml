import bb.cascades 1.4

Container {
    id: root

    property variant date: new Date() 
    property variant result: new Date()
    
    function value() {
        return deadlineDateTimePicker.value;
    }   
    
    Container {
        leftPadding: ui.du(2.5)
        topPadding: ui.du(2.5)
        rightPadding: ui.du(2.5)
        
        DateTimePicker {
            id: deadlineDateTimePicker
            title: qsTr("Date") + Retranslate.onLocaleOrLanguageChanged
            mode: DateTimePickerMode.DateTime
            value: date
            
            onValueChanged: {
                root.result = value;
            }
        }
    }
    
    Divider {}
    
    onCreationCompleted: {
        root.result = root.date;
    }
}
