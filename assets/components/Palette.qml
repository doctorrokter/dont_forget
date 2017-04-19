import bb.cascades 1.4

Container {
    id: root
    
    signal colorChosen(string color)
    
    property string color: blue.color
    
    property variant colors: {
        BLUE: "#0092CC",
        RED: "#FF3333",
        YELLOW: "#DCD427",
        GREEN: "#779933",
        GREY: "#969696",
        MAGENTA: "#8b008b",
        BLACK: "#323232"
    };
    
    horizontalAlignment: HorizontalAlignment.Fill
    maxHeight: ui.du(12)
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    ColorControl {
        id: blue
        
        color: root.colors.BLUE
        checked: true
        
        onClicked: {
            processColorClick(color);
        }
    }
    
    ColorControl {
        id: red
        
        color: root.colors.RED
        
        onClicked: {
            processColorClick(color);
        }
    }
    
    ColorControl {
        id: yellow
        
        color: root.colors.YELLOW
        
        onClicked: {
            processColorClick(color);
        }
    }
    
    ColorControl {
        id: green
        
        color: root.colors.GREEN
        
        onClicked: {
            processColorClick(color);
        }
    }
    
    ColorControl {
        id: grey
        
        color: root.colors.GREY
        
        onClicked: {
            processColorClick(color);
        }
    }
    
    ColorControl {
        id: magenta
        
        color: root.colors.MAGENTA
        
        onClicked: {
            processColorClick(color);
        }
    }
    
    
    ColorControl {
        id: black
        
        color: root.colors.BLACK
        
        onClicked: {
            processColorClick(color);
        }
    }
    
    onColorChanged: {
        processColorClick(color);
    }
    
    function processColorClick(newColor) {
        for(var i = 0; i < root.controls.length; i++) {
            var cc = root.controls[i];
            cc.checked = cc.color === newColor;
            colorChosen(newColor);
        }
        root.color = newColor;
    }
}
