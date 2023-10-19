import CanvasAppKit
import Canvas
import Navigator
import Settings
import AppKit
import Document
import Combine
import TextRecognition
import Presentation
import SwiftUI

extension CanvasPresenter: TextBasedPresenter {}

class ProjectController: NSSplitViewController {
    
    init(
        document: VODesignDocument,
        router: ProjectRouterDelegate
    ) {
        self.router = router
        self.document = document
        
        let canvasPresenter = CanvasPresenter(document: document)
        
        navigator = NavigatorController.fromStoryboard(
            document: document,
            presenter: canvasPresenter)
        
        canvas = CanvasViewController.fromStoryboard()
        canvas.inject(presenter: canvasPresenter)
        
        settings = SettingsStateViewController.fromStoryboard()
        settings.textRecognitionCoordinator = TextRecognitionCoordinator(
            imageSource: canvas)
        
        super.init(nibName: nil, bundle: nil)
        
        settings.settingsDelegate = self
    
        // Should be handled by cancelOperation, but the function not calling https://stackoverflow.com/a/7777469/3300148
        keyListener = NSEvent.addLocalMonitorForEvents(matching: [.keyDown], handler: { [weak self] event in
            let escapeKeyCode: UInt16 = 53
            if event.keyCode == escapeKeyCode {
                if self?.mode == .presentation {
                    self?.stopPresentation()
                }
            }
            return event
        })
    }
    
    var keyListener: Any?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let navigator: NavigatorController
    let canvas: CanvasViewController
    private let settings: SettingsStateViewController
    private(set) weak var router: ProjectRouterDelegate?

    private lazy var textSidebar: NSSplitViewItem = {
        let textSidebar = NSSplitViewItem(sidebarWithViewController: navigator)
        textSidebar.minimumThickness = 250
        textSidebar.allowsFullHeightLayout = true
        textSidebar.isSpringLoaded = true
        return textSidebar
    }()

    private lazy var canvasItem = NSSplitViewItem(viewController: canvas)

    private lazy var settingsSidebar: NSSplitViewItem = {
        let settingsSplit = NSSplitViewItem(inspectorWithViewController: settings)
        settingsSplit.minimumThickness = 400
        settingsSplit.maximumThickness = 400
        return settingsSplit
    }()

    var document: VODesignDocument!
    private var cancellables = Set<AnyCancellable>()

    enum Mode {
        case editor
        case presentation
    }

    private var mode: Mode?

    override func viewDidLoad() {
        super.viewDidLoad()

        toggle(.editor)
        addMenuItem()
    }

    func toggle(_ newMode: Mode) {
        guard newMode != mode else {
            return
        }
        defer { mode = newMode }
        document?.save(self)

        let window = view.window
//        window?.toggleToolbarShown(self)
//        window?.toggleFullScreen(self)
//        window?.titlebarAppearsTransparent = true
        
        switch newMode {
        case .editor:
//            window?.styleMask.formUnion(.titled)
//            window?.toolbar = toolbar
            
            splitViewItems.forEach { removeSplitViewItem($0) }
            addSplitViewItem(textSidebar)
            addSplitViewItem(canvasItem)
            addSplitViewItem(settingsSidebar)
            
        case .presentation:
//            window?.styleMask.remove(.titled)
            NSApplication.shared.presentationOptions.formUnion(.autoHideToolbar)
            
            splitViewItems.forEach { removeSplitViewItem($0) }
            
            
            let controller = presentation(document: document)
            addSplitViewItem(NSSplitViewItem(viewController: controller))
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        canvas.presenter
            .selectedPublisher
            .sink(receiveValue: updateSelection(_:))
            .store(in: &cancellables)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        
        canvas.presenter.stopObserving()
    }
    
    public var toolbar: NSToolbar {
        let toolbar: NSToolbar = NSToolbar()
        toolbar.delegate = self
        return toolbar
    }
    
    private func addMenuItem() {
        guard let menu = NSApplication.shared.menu else { return }
        guard menu.item(withTitle: NSLocalizedString("Play", comment: "")) == nil else { return }
        
        menu.insertItem(canvas.makeCanvasMenu(), at: 3)
        menu.insertItem(makePlayPresentationMenu(), at: 4)
    }
    
    let playMenuItem = NSMenuItem(title: NSLocalizedString("Play", comment: ""), 
                                  action: #selector(enablePresentation),
                                  keyEquivalent: "p")
    let stopMenuItem = NSMenuItem(title: NSLocalizedString("Stop", comment: ""), 
                                  action: #selector(stopPresentation),
                                  keyEquivalent: "\(KeyEquivalent.escape.character)")
    
    private func makePlayPresentationMenu() -> NSMenuItem {
        let slideshowMenu = NSMenuItem(title: "Play", action: nil, keyEquivalent: "")
        let slideshowSubmenu = NSMenu(title: "Play")
        slideshowSubmenu.autoenablesItems = false
        slideshowSubmenu.addItem(playMenuItem)
        slideshowSubmenu.addItem(stopMenuItem)
        slideshowMenu.submenu = slideshowSubmenu
        
        stopMenuItem.isHidden = true
        stopMenuItem.keyEquivalentModifierMask = []
        
        return slideshowMenu
    }
}

// MARK: Settings visibility
extension ProjectController {
    private func updateSelection(_ selectedModel: (any AccessibilityView)?) {
        if let selectedModel = selectedModel {
            showSettings(for: selectedModel)
        } else {
            hideSettings()
        }
    }

    func showSettings(for model: any AccessibilityView) {
        switch model.cast {
        case .container(let container):
            settings.state = .container(container)
        case .element(let element):
            settings.state = .control(element)
        }
    }
    
    func hideSettings() {
        settings.state = .empty
    }

    private func presentation(document: VODesignDocument) -> NSViewController {
        let hostingController = NSHostingController(rootView: PresentationView(
            document: .init(document)
        ))
        hostingController.title = NSLocalizedString("Presentation", comment: "")
        return hostingController
    }
}

extension ProjectController: SettingsDelegate {
    public func updateValue() {
        canvas.publishControlChanges()
    }
    
    public func delete(model: any AccessibilityView) {
        canvas.delete(model: model)
        settings.state = .empty
    }
}

extension CanvasViewController: RecognitionImageSource {}
