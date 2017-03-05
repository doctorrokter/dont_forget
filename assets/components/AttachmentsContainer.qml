import bb.cascades 1.4

Container {
    id: root
    
    property variant attachments: []
    
    visible: false
    horizontalAlignment: HorizontalAlignment.Fill
    
    Header {
        title: qsTr("Attachments") + Retranslate.onLocaleOrLanguageChanged
    }
    
    ListView {
        id: attachmentsListView
        
        dataModel: ArrayDataModel {
            id: attachmentsDataModel
            
            onItemAdded: {
                adjustHeight();
            }
        }
        
        listItemComponents: [
            ListItemComponent {
                StandardListItem {
                    imageSource: ListItemData.icon
                    title: ListItemData.name
                    
                    contextActions: [
                        ActionSet {
                            DeleteActionItem {
                                onTriggered: {
                                    if (ListItemData.id) {
                                        _attachmentsService.remove(ListItemData.id);
                                    } else {
                                        _attachmentsService.remove();
                                    }
                                }
                            }
                        }
                    ]
                }
            }
        ]
                
        onTriggered: {
            var item = attachmentsDataModel.data(indexPath);
            _app.invokePreviewer(item.path, item.mime_type);
        }
    }
    
    function adjustHeight() {
        root.maxHeight = attachmentsDataModel.size() * 250;
    }
    
    function fill() {
        root.visible = root.attachments.length !== 0;
        var newAttachments = root.attachments.map(function(a) {
            if (a.mime_type === "application/pdf") {
                a.icon = "asset:///images/pdf_icon.png";
            } else {
                a.icon = a.path;
            }
            return a;
        });
        
        attachmentsDataModel.clear();
        attachmentsDataModel.append(newAttachments);
        adjustHeight();
    }
    
    function addAttachment(attachment) {
        attachmentsDataModel.append(attachment);
    }
    
    function removeAttachment(id) {
        if (id !== 0) {
            var newAttachments = root.attachments.filter(function(a) {
                return a.id !== id;
            });
            root.attachments = newAttachments;
        } else {
            root.attachments = [];            
        }
    }
    
    onCreationCompleted: {
        fill();
        _attachmentsService.attachmentRemoved.connect(root.removeAttachment);
    }
    
    onAttachmentsChanged: {
        fill();
    }
}