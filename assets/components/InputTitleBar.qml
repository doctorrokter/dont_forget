import bb.cascades 1.4

TitleBar {
    id: root
    
    signal cancel();
    signal typing(string text);
    signal submit(string text);

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
                        root.submit(tasksInputField.text.trim());
                    }
                }
                textStyle.color: ui.palette.textOnPrimary
                
                onTextChanging: {
                    root.typing(text);
                }
            }
            
            Button {
                text: "X"
                maxWidth: ui.du(5)
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