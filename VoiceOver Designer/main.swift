import AppKit

// 1
let app = NSApplication.shared
let delegate = AppDelegate()
let menu = MainMenu.menu()
app.delegate = delegate
app.mainMenu = menu

// 2
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
