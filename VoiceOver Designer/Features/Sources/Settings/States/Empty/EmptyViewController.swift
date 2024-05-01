import AppKit


class EmptyViewController: NSViewController {
    public static func fromStoryboard() -> Self {
        let storyboard = NSStoryboard(name: "EmptyViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! Self
    }
}
