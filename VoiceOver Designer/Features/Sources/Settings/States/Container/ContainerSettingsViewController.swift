import AppKit

class ContainerSettingsViewController: NSViewController {
    
    public static func fromStoryboard() -> ContainerSettingsViewController {
        let storyboard = NSStoryboard(name: "ContainerSettingsViewController",
                                      bundle: .module)
        return storyboard.instantiateInitialController() as! ContainerSettingsViewController
    }
}
