import bb.cascades 1.4

Container {
    layout: DockLayout {}
    
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    
    background: {
        if (Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright) {
            return ui.palette.plain;
        }
        return ui.palette.background;
    }
    
    ImageView {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        scalingMethod: ScalingMethod.AspectFill
        imageSource: _ui.backgroundImage
        visible: _ui.backgroundImage !== "asset:///images/backgrounds/"
    }
}
