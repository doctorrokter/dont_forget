import bb.cascades 1.4

TitleBar {
    id: root
    
    property int taskId: 0
    property string taskType: ""
    
    signal submit();
    signal cancel();
    
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
                id: createTaskField
                backgroundVisible: false
                textStyle.color: Color.White
                hintText: qsTr("Enter name or names: Task1;;Task2;;Task3") + Retranslate.onLocaleOrLanguageChanged
                inputMode: TextFieldInputMode.Text
                input {
                    submitKey: SubmitKey.EnterKey
                    onSubmitted: {
                        createTaskField.submit();
                    }
                }
                
                keyListeners: [
                    KeyListener {
                        onKeyReleased: {
                            if (event.key === 13) {
                                createTaskField.submit();
                            }
                        }
                    }
                ]
                
                function submit() {
                    if (createTaskField.text.trim() !== "") {
                        var names = createTaskField.text.split(";;");
                        names.forEach(function(name) {
                                if (name.trim() !== "") {
                                    _tasksService.createTask(name.trim(), root.taskType, root.taskId);
                                }    
                        });
                        root.reset();
                        root.submit();
                    }
                }
            }
            
            Button {
                text: "X"
                maxWidth: ui.du(5)
                color: ui.palette.primary
                
                onClicked: {
                    root.reset();
                    root.cancel();
                }
            }
        }
    }
    
    function focus() {
        createTaskField.requestFocus();
    }
    
    function reset() {
        root.taskType = "";
        root.taskId = 0;
        createTaskField.resetText();
    }
}
