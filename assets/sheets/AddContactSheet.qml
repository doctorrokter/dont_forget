import bb.cascades 1.4
import "../components"

Sheet {
    id: contactSheet
    
    property int userId: 0
    property string firstName: ""
    property string lastName: ""
    property string pin: ""
    
    property string mode: "CREATE"
    property variant modes: {
        CREATE: "CREATE",
        UPDATE: "UPDATE"
    }
    
    Page {
        id: root
    
        titleBar: CustomTitleBar {
            title: {
                if (mode === modes.CREATE) {
                    return qsTr("Add user") + Retranslate.onLocaleOrLanguageChanged;
                }
                return qsTr("Update user") + Retranslate.onLocaleOrLanguageChanged;
            }
            
            cancelAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    contactSheet.close();    
                }
            }
            
            submitAction: ActionItem {
                title: qsTr("OK") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    var firstName = firstNameField.text.trim();
                    var lastName = lastNameField.text.trim();
                    var pin = pinField.text.trim();
                    var error = firstName === '';
                    if (error) {
                        firstNameRequired.visible = true;
                    }
                    
                    error = pin === '';
                    if (error) {
                        pinRequired.visible = true;
                    }
                    
                    if (!error) {
                        if (userId !== 0) {
                            _usersService.update(userId, firstName, lastName, pin);
                        } else {
                            _usersService.add(firstName, lastName, pin);
                        }
                        contactSheet.close();
                    }
                }
            }
        }
    
        ScrollView {
            scrollRole: ScrollRole.Main
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
        
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
            
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    leftPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    Label {
                        text: qsTr("First name") + Retranslate.onLocaleOrLanguageChanged
                    }
                    
                    Label {
                        id: firstNameRequired
                        visible: false
                        text: qsTr("required") + Retranslate.onLocaleOrLanguageChanged
                        textStyle {
                            fontWeight: FontWeight.W100
                            color: Color.create("#FF3333")
                        }
                    }
                }
            
                TextField {
                    id: firstNameField
                    inputMode: TextFieldInputMode.Text
                    text: firstName
                }
            
                Container {
                    leftPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    Label {
                        text: qsTr("Last name") + Retranslate.onLocaleOrLanguageChanged
                    }
                }
            
                TextField {
                    id: lastNameField
                    inputMode: TextFieldInputMode.Text
                    text: lastName
                }
            
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    leftPadding: ui.du(2.5)
                    topPadding: ui.du(2.5)
                    Label {
                        text: qsTr("PIN") + Retranslate.onLocaleOrLanguageChanged
                    }
                    Label {
                        id: pinRequired
                        visible: false
                        text: qsTr("required") + Retranslate.onLocaleOrLanguageChanged
                        textStyle {
                            fontWeight: FontWeight.W100
                            color: Color.create("#FF3333")
                        }
                    }
                }
                
                TextField {
                    id: pinField
                    inputMode: TextFieldInputMode.Text
                    text: pin
                }
            }
        }
    }
    
    onClosed: {
        userId = 0;
        firstName = "";
        lastName = "";
        pin = "";
        mode = "CREATE";
        firstNameField.resetText();
        lastNameField.resetText();
        pinField.resetText();
    }
}
