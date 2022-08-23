import AppKit

public class MainMenu: NSMenu {
    public static func menu() -> NSMenu {
        var topLevelObjects: NSArray? = []
        
        Bundle(for: MainMenu.self)
            .loadNibNamed("MainMenu", owner: self, topLevelObjects: &topLevelObjects)
        
        return topLevelObjects?.filter { $0 is NSMenu }.first as! NSMenu
    }
}
