import bb.cascades 1.4

TitleBar {
    id: root
    
    signal cancel();
    signal typing(string text);

    appearance: TitleBarAppearance.Plain
    kind: TitleBarKind.FreeForm
    
    kindProperties: FreeFormTitleBarKindProperties {
        Container {
            background: ui.palette.primaryBase
            leftPadding: ui.du(1.5)
            rightPadding: ui.du(1.5)
            topPadding: ui.du(1.5)
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            
            TextField {
                id: tasksInputField
                
                backgroundVisible: false
                inputMode: TextFieldInputMode.Text
                
                input {
                    keyLayout: KeyLayout.Text
                    submitKey: SubmitKey.EnterKey
                    onSubmitted: {
                        var inputText = tasksInputField.text;
                        if (inputText.trim()) {
                            var names = tasksInputField.text.split(";;");
                            names.forEach(function(name) {
                                    _tasksService.createTask(name.trim(), "", "TASK");
                            });
                            root.cancel();
                        }
                        tasksInputField.resetText();
                    }
                }
                textStyle.color: ui.palette.textOnPrimary
                
                onTextChanging: {
                    root.typing(text);
                }
            }
            
            Button {
                text: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                maxWidth: ui.du(20)
                color: ui.palette.primary
                
                onClicked: {
                    root.cancel();
                }
            }
        }
    }
    
    function focus() {
        tasksInputField.requestFocus();
    }
    
    function reset() {
        tasksInputField.resetText();
    }
}