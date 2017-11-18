import bb.cascades 1.4
import "./v2/"

Container {
    id: root

    property int taskId: 0
    
    Mover {
        taskId: root.taskId
    }
}
