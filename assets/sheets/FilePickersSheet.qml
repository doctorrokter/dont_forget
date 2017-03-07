import bb.cascades 1.4
import bb.cascades.pickers 1.0
import "../components"

Sheet {
    id: sheet
    
    signal attachmentsChosen(variant attachments);
    
    Page {
        id: page
        
        property variant mimes: {
            "doc": "application/msword",
            "dot": "application/msword",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "docm": "application/vnd.ms-word.document.macroEnabled.12",
            "dotx": "application/vnd.openxmlformats-officedocument.wordprocessingml.template",
            "dotm": "application/vnd.ms-word.template.macroEnabled.12",
            "txt": "text/plain",
            
            "xls": "application/vnd.ms-excel",
            "xlt": "application/vnd.ms-excel",
            "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "xltx": "application/vnd.openxmlformats-officedocument.spreadsheetml.template",
            "xlsm": "application/vnd.ms-excel.sheet.macroEnabled.12",
            "xltm": "application/vnd.ms-excel.template.macroEnabled.12",
            
            "ppt": "application/vnd.ms-powerpoint",
            "pot": "application/vnd.ms-powerpoint",
            "pps": "application/vnd.ms-powerpoint",
            "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "potx": "application/vnd.openxmlformats-officedocument.presentationml.template",
            "ppsx": "application/vnd.openxmlformats-officedocument.presentationml.slideshow",
            "pptm": "application/vnd.ms-powerpoint.presentation.macroEnabled.12",
            "potm": "application/vnd.ms-powerpoint.template.macroEnabled.12",
            "ppsm": "application/vnd.ms-powerpoint.slideshow.macroEnabled.12",
            
            "pdf": "application/pdf",
            "apk": "application/vnd.android.package-archive",
            "zip": "application/zip",
            "js": "application/javascript",
            "json": "application/json"
        }
        
        titleBar: CustomTitleBar {
            title: qsTr("Choose a type") + Retranslate.onLocaleOrLanguageChanged
            
            cancelAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    sheet.close();
                }
            }
        }
        
        ListView {
            id: pickersList
            
            dataModel: ArrayDataModel {
                id: pickersDataModel
            }
            
            listItemComponents: [
                ListItemComponent {
                    CustomListItem {
                        horizontalAlignment: HorizontalAlignment.Fill
                        Container {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            ImageView {
                                verticalAlignment: VerticalAlignment.Center
                                filterColor: Color.create(ListItemData.color)
                                imageSource: ListItemData.icon
                            }
                            
                            Label {
                                verticalAlignment: VerticalAlignment.Center
                                text: ListItemData.title
                                textStyle.base: SystemDefaults.TextStyles.TitleText
                            }
                        }
                    }
                }
            ]
            
            onTriggered: {
                var item = pickersDataModel.data(indexPath);
                switch (item.picker) {
                    case FileType.Picture: picturePicker.open(); break;
                    case FileType.Document: docPicker.open(); break;
                    case FileType.Music: musicPicker.open(); break;
                    case FileType.Video: videoPicker.open(); break;
                }
            }
            
            onCreationCompleted: {
                var data = [];
                data.push({color: "#779933", icon: "asset:///images/ic_doctype_picture.png", title: qsTr("Picture") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Picture});
                data.push({color: "#969696", icon: "asset:///images/ic_doctype_generic.png", title: qsTr("Document") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Document});
                data.push({color: "#8F3096", icon: "asset:///images/ic_doctype_music.png", title: qsTr("Music") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Music});
                data.push({color: "#FF3333", icon: "asset:///images/ic_doctype_video.png", title: qsTr("Video") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Video});
                pickersDataModel.append(data);
            }
        }
        
        function toAttachments(selectedFiles, baseMimeType) {
            return selectedFiles.map(function(f) {
                var nameExt = page.getNameAndExt(f);
                return {path: "file://" + f, name: nameExt.name, mime_type: baseMimeType + "/" + nameExt.ext};
            });
        }
        
        function getNameAndExt(filePath) {
            var parts = filePath.split("/");
            var name = parts[parts.length - 1];
            var dotParts = name.split(".");
            var ext = dotParts[dotParts.length - 1];
            return {name: name, ext: ext};
        }
        
        function setAttachments(attachments) {
            sheet.attachmentsChosen(attachments);
            sheet.close();
        }
        
        attachedObjects: [
            FilePicker {
                id: picturePicker
                
                type: FileType.Picture
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged

                onFileSelected: {
                    var attachments = page.toAttachments(selectedFiles, "image");
                    page.setAttachments(attachments);
                }
            },
            
            FilePicker {
                id: docPicker
                
                type: FileType.Document
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged

                onFileSelected: {
                    var attachments = selectedFiles.map(function(f) {
                        var nameExt = page.getNameAndExt(f);
                        var mime = page.mimes[nameExt.ext];
                        return {path: "file://" + f, name: nameExt.name, mime_type: mime === undefined ? "application/" + nameExt.ext : mime};
                    });
                    page.setAttachments(attachments);
                }
            },
            
            FilePicker {
                id: musicPicker
                
                type: FileType.Music
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged
                
                onFileSelected: {
                    var attachments = page.toAttachments(selectedFiles, "audio");
                    page.setAttachments(attachments);
                }
            },
            
            FilePicker {
                id: videoPicker
                
                type: FileType.Video
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged
                
                onFileSelected: {
                    var attachments = page.toAttachments(selectedFiles, "video");
                    page.setAttachments(attachments);
                }
            }
        ]
    }
}