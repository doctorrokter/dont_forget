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
            
            onItemRemoved: {
                adjustHeight();
            }
        }
        
        function indexOf(data) {
            return attachmentsDataModel.indexOf(data);
        }
        
        function removeAt(index) {
            attachmentsDataModel.removeAt(index);
            var toRemove = root.attachments[index];
            if (toRemove) {
                root.attachments = root.attachments.filter(function(a) {
                    return a.path !== toRemove.path;
                });
            }
            
        }
        
        listItemComponents: [
            ListItemComponent {
                CustomListItem {
                    id: attachmentItem
                    preferredHeight: ui.du(12)
                    maxHeight: ui.du(12)
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    Container {
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        Container {
                            maxWidth: ui.du(12)
                            preferredWidth: ui.du(12)
                            verticalAlignment: VerticalAlignment.Fill
                            
                            ImageView {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                filterColor: {
                                    if (ListItemData.icon.color) {
                                        return Color.create(ListItemData.icon.color);
                                    }
                                    return null;
                                }
                                imageSource: ListItemData.icon.path
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: -1
                                }
                            }
                        }
                        
                        
                        Label {
                            verticalAlignment: VerticalAlignment.Center
                            text: ListItemData.name
                            textStyle.base: SystemDefaults.TextStyles.TitleText
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                        }
                    }
                    
                    contextActions: [
                        ActionSet {
                            DeleteActionItem {
                                onTriggered: {
                                    var index = attachmentItem.ListItem.view.indexOf(ListItemData);
                                    var attach = ListItemData;
                                    if (attach.id) {
                                        _attachmentsService.remove(attach.id);
                                    } else {
                                        attachmentItem.ListItem.view.removeAt(index);
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
            _attachmentsService.showAttachment(item.path, item.mime_type);
        }
    }
    
    function adjustHeight() {
        root.maxHeight = (attachmentsDataModel.size() + 0.5) * ui.du(12);
    }
    
    function fill() {
        root.visible = root.attachments.length !== 0;
        var newAttachments = root.attachments.map(function(a) {
            console.debug(a);
            if (a.mime_type.indexOf("image/") !== -1) {
                a.icon = {path: a.path, color: ""};
            } else {
                var ext = _attachmentsService.getExtension(a.path);
                var iconAndColor = _attachmentsService.getIconColorMap(ext, a.mime_type);
                a.icon = {path: "asset:///images/" + iconAndColor.image, color: iconAndColor.color};
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