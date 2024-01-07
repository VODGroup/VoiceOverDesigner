enum FileName {
    static let screen = "screen.png"
    static let controls = "controls.json"
    static let document = "document.json"
    static let info = "info.json"
    static let quickLookFile = "Preview.heic"
}

public enum FolderName {
    static let quickLook = "QuickView"
    static let images = "Images"
    
    public static var quickLookPath: String {
        "\(FolderName.quickLook)/\(FileName.quickLookFile)"
    }
}

public let vodesign = "vodesign"
public let uti = "com.akaDuality.vodesign"
public let defaultFrameName = "Frame"
