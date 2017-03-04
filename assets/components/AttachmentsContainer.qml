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
    
    onCreationCompleted: {
        fill();
    }
    
    onAttachmentsChanged: {
        fill();
    }
}