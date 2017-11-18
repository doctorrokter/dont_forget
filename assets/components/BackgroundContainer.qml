import bb.cascades 1.4

Container {
    layout: DockLayout {}
    
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    
    background: ui.palette.plainBase
    
    ImageView {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        scalingMethod: ScalingMethod.AspectFill
        imageSource: _ui.backgroundImage
    }
}
