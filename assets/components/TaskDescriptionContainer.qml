import bb.cascades 1.4

Container {
    id: root
    
    property string value: ""
    property string result: ""
    
    function resetText() {
        root.value = "";
        textArea.resetText();
    }
    
    function requestFocus() {
        textArea.requestFocus();
    }
    
    TextArea {
        id: textArea
        textFormat: TextFormat.Auto
        minHeight: ui.du(25)
        autoSize.maxLineCount: 10
        scrollMode: TextAreaScrollMode.Elastic
        inputMode: TextAreaInputMode.Text
        hintText: qsTr("Notes...") + Retranslate.onLocaleOrLanguageChanged
        
        onTextChanging: {
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
