import bb.cascades 1.4
import "../components"

Page {
    id: root
    
    signal imageChanged(string image)
    
    titleBar: CustomTitleBar {
        title: qsTr("Choose a background") + Retranslate.onLocaleOrLanguageChanged
    }
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        ListView {
            id: listView
            
            dataModel: ArrayDataModel {
                id: dataModel
            }
            
            layout: GridListLayout {
                columnCount: 2
            }
            
            onTriggered: {
                listView.clearSelection();
                listView.select(indexPath);
            }
            
            listItemComponents: [
                ListItemComponent {
                    CustomListItem {
                        id: imageListItem
                        
                        property bool selected: ListItem.selected
                        
                        opacity: imageListItem.selected ? 0.75 : 1.0
                        Container {
                            horizontalAlignment: HorizontalAlignment.Fill
                            layout: DockLayout {}
                            
                            ImageView {
                                scalingMethod: ScalingMethod.AspectFill
                                imageSource: "asset:///images/backgrounds/" + ListItemData
                            }
                            
                            ImageView {
                                visible: imageListItem.selected
                                imageSource: "asset:///images/ic_done.png"
                                verticalAlignment: VerticalAlignment.Center
                                horizontalAlignment: HorizontalAlignment.Center
                            }
                        }
                    }
                }
            ]
        }
    }
    
    actions: [
        ActionItem {
            id: setImageAction
            imageSource: "asset:///images/ic_done.png"
            ActionBar.placement: ActionBarPlacement.Signature
            title: "Ok"
            
            onTriggered: {
                var img = dataModel.data(listView.selected());
                _appConfig.set("background_image", img);
                _ui.backgroundImage = img;
                root.imageChanged(img);
            }
        }
    ]
    
    onCreationCompleted: {
        var data = _app.images;
        dataModel.append(data);
    }
}
