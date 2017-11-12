import bb.cascades 1.4
import "../components"

Page {
    
    id: root
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Overlay
    
    titleBar: CustomTitleBar {
        title: qsTr("Charts") + Retranslate.onLocaleOrLanguageChanged
    }
    
    ScrollView {
        scrollRole: ScrollRole.Main     
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill   
        
        Container {
            WebView {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                url: "local:///assets/html/charts.html"
                settings.viewport: {"width":"device-width", "initial-scale":1.0 }
                
                onMessageReceived: {
                    console.debug(message);
                }
            }
            
            Container {
                minHeight: ui.du(12)
            }
        }
        
    }
}
