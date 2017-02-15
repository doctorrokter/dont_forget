import bb.cascades 1.4

Container {
    id: root
    
    property string value: ""
    property string result: ""
    
    function resetText() {
        root.value = "";
        textField.resetText();
    }
    
    Container {
        leftPadding: ui.du(2.5)
        topPadding: ui.du(2.5)
        Label {
            text: qsTr("Name") + Retranslate.onLocaleOrLanguageChanged
        }
    }
    
    TextField {
        id: textField
        text: value
        inputMode: TextFieldInputMode.Text
        
        onTextChanging: {
            root.result = text;
        }
    }
    
    onCreationCompleted: {
        root.result = root.value;
    }
    
    onValueChanged: {
        textField.text = value;
    }
}