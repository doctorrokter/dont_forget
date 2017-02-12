import bb.cascades 1.4

NavigationPane {
    id: navigation
    
    backButtonsVisible: true
    peekEnabled: true
    
    Page {
        id: root
        
        function setTitle(title) {
            titleLabel.text = title;
        }
        
        Container {
            Header {
                title: "TEST"
            }
            
            Label {
                id: titleLabel
            }
            
            Label {
                id: label
                text: _data
                multiline: true
            }
        }
        
        onCreationCompleted: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", _data, true);
            xhr.onreadystatechange = function() { 
                if (xhr.readyState == 4) {
                    var title = (/<title>(.*?)<\/title>/m).exec(xhr.responseText)[1];
                    root.setTitle(title); 
                }
            }
            xhr.send();
        }
    }
}

