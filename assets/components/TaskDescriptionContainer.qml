import bb.cascades 1.4

Container {
    id: root
    
    property string value: ""
    property string result: ""
    
    function resetText() {
        root.value = "";
    }
    
    Container {
        leftPadding: ui.du(2.5)
        topPadding: ui.du(2.5)
        Label {
            text: qsTr("Description") + Retranslate.onLocaleOrLanguageChanged
        }
    }
    
    TextArea {
        id: textArea
//        text: value
        textFormat: TextFormat.Auto
        minHeight: ui.du(25)
        autoSize.maxLineCount: 10
        scrollMode: TextAreaScrollMode.Elastic
        inputMode: TextAreaInputMode.Text
        
        onTextChanged: {
            root.result = text;
        }
    }
    
    onCreationCompleted: {
        root.result = root.value;
    }
    
    onValueChanged: {
        textArea.text = value;
    }
}
