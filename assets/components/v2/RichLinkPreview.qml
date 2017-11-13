import bb.cascades 1.4
import WebPageComponent 1.0

Container {
    id: root
    
    property string url: ""
    property string site: "Onliner.by"
    property string title: ""
    property string description: "The mega description for the super link"
    property string imageSource: "asset:///images/backgrounds/wall_1.jpg"
    
    horizontalAlignment: HorizontalAlignment.Fill
    
    leftPadding: ui.du(1)
    topPadding: ui.du(1)
    rightPadding: ui.du(1)
    
    onUrlChanged: {
        urlLabel.text = "<a href=\"" + root.url + "\">" + root.url + "</a>";
    }
    
    Container {
        bottomMargin: ui.du(1)
        Label {
            id: urlLabel
            textFormat: TextFormat.Html
            multiline: true
        }
    }
    
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        Container {
            preferredWidth: ui.du(0.75)
            preferredHeight: mainLUH.layoutFrame.height
            background: ui.palette.primaryBase
        }
        
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            
            leftPadding: ui.du(1)
            
            Container {
                Label {
                    text: root.site
                    textStyle.color: ui.palette.primaryBase
                    multiline: true
                }
            }
            
            Container {
                Label {
                    text: root.title
                    multiline: true
                    textStyle.fontWeight: FontWeight.W600
                }
            }
            
            Container {
                Label {
                    text: root.description
                    textFormat: TextFormat.Html
                    multiline: true
                }
            }
            
            ImageView {
                horizontalAlignment: HorizontalAlignment.Fill
                imageSource: root.imageSource
                scalingMethod: ScalingMethod.AspectFill
                maxHeight: ui.du(35)
            }
            
            attachedObjects: [
                LayoutUpdateHandler {
                    id: mainLUH
                }
            ]
        }
    }
    
    function load() {
        webPage.url = root.url;
    }
    
    attachedObjects: [
        WebPage {
            id: webPage
            
            onTitleChanged: {
                root.title = title;
                
                var titleScript = 'document.querySelector(\'meta[property="og:title"]\').content';
                evaluateJavaScript(titleScript, JavaScriptWorld.Normal);
                
                var imgScript = 'document.querySelector(\'meta[property="og:image"]\').content';
                evaluateJavaScript(imgScript, JavaScriptWorld.Normal);
                
                var descScript = 'document.querySelector(\'meta[property="og:description"]\').content';
                evaluateJavaScript(descScript, JavaScriptWorld.Normal);
            }
            
            onJavaScriptResult: {
                console.debug("===>>> JS");
                console.debug("id: ", resultId);
                console.debug("result: ", result);
            }
            
            onLoadingChanged: {
                if (loadRequest.status == WebLoadStatus.Succeeded) {
//                    var titleScript = 'document.querySelector(\'meta[property="og:title"]\').content';
//                    webPage.evaluateJavaScript(titleScript, JavaScriptWorld.Normal);
//                    
//                    var imgScript = 'document.querySelector(\'meta[property="og:image"]\').content';
//                    webPage.evaluateJavaScript(imgScript, JavaScriptWorld.Normal);
//                    
//                    var descScript = 'document.querySelector(\'meta[property="og:description"]\').content';
//                    webPage.evaluateJavaScript(descScript, JavaScriptWorld.Normal);
                }
//                if (loadRequest.status == WebLoadStatus.Started) {
//                    console.debug("Load started.");
//                }
//                else if (loadRequest.status == WebLoadStatus.Succeeded) {
//                    console.debug("Load finished.");
//                }
//                else if (loadRequest.status == WebLoadStatus.Failed) {
//                    console.debug("Load failed.");
//                }
            }
        }
    ]
}
