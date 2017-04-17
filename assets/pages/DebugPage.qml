import bb.cascades 1.4

Page {
    
    ListView {
        id: listView
        
        dataModel: ArrayDataModel {
            id: dataModel
        }
        
        listItemComponents: [
            ListItemComponent {
                CustomListItem {
                    horizontalAlignment: HorizontalAlignment.Fill
                    Container {
                        horizontalAlignment: HorizontalAlignment.Fill
                        layout: GridLayout {
                            columnCount: 4
                        }
                        
                        leftPadding: ui.du(1.5)
                        topPadding: ui.du(1.5)
                        rightPadding: ui.du(1.5)
                        bottomPadding: ui.du(1.5)
                        
                        Container {
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Center
                            Label {
                                text: ListItemData.id
                            }
                        }
                        
                        Container {
                            verticalAlignment: VerticalAlignment.Center
                            maxWidth: ui.du(10)
                            Label {
                                text: ListItemData.name
                                multiline: true
                            }
                        }
                        
                        Container {
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center

                            DropDown {
                                id: parentId
                                maxWidth: ui.du(10)
                                options: [
                                    Option {
                                        text: ListItemData.parent_id
                                        value: ListItemData.parent_id
                                        selected: true
                                    },
                                    
                                    Option {
                                        text: qsTr("Root") + Retranslate.onLocaleOrLanguageChanged
                                        value: 0
                                        enabled: ListItemData.parent_id !== ""
                                        selected: ListItemData.parent_id === ""
                                    }
                                ]
                            }
                        }
                        
                        Container {
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            maxWidth: ui.du(20)
                            Button {
                                horizontalAlignment: HorizontalAlignment.Fill
                                text: qsTr("Update") + Retranslate.onLocaleOrLanguageChanged
                                
                                onClicked: {
                                    _tasksService.changeParentIdInDebug(ListItemData.id, parentId.selectedValue);
                                }
                            }
                        }
                    }
                }
            }
        ]
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: row
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
            }    
        },
        
        ComponentDefinition {
            id: label
            Label {
                textStyle.base: SystemDefaults.TextStyles.BodyText
            }
        }
    ]
    
    onCreationCompleted: {
        var tasks = _tasksService.findAll();
        dataModel.append(tasks);        
    }
}
