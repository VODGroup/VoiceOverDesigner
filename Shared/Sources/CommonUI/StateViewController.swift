//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 21.08.2021.
//

#if os(iOS) || os(visionOS)
import UIKit
public typealias AppViewController = UIViewController
public typealias AppView = UIView
public typealias AppEdgeInsets = UIEdgeInsets
#elseif os(macOS)
import AppKit
public typealias AppViewController = NSViewController
public typealias AppView = NSView
public typealias AppEdgeInsets = NSEdgeInsets
#endif

public protocol StateProtocol: Equatable {
    static var `default`: Self { get }
}

open class StateViewController<State>: AppViewController
where State: StateProtocol {
    
    open var stateFactory: ((State) -> AppViewController)!

    open var shouldSetDefaultControllerOnViewDidLoad: Bool = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    
        if shouldSetDefaultControllerOnViewDidLoad {
            addController(for: state)
        }
    }
    
    
    open override func loadView() {
        view = AppView()
    }
    
    // MARK: State
    
    open var state: State = .default {
        didSet {
            let isChanged = state != oldValue
            if isChanged 
                || currentController == nil // if shouldSetDefaultControllerOnViewDidLoad = false
            {
                removeCurrentIfExists()
                addController(for: state)
            }
        }
    }
    
    // MARK: Controller management
    
    public private(set) weak var currentController: AppViewController?
    
    private func addController(for state: State) {
        addNew(stateFactory(state))
    }
#if os(iOS) || os(visionOS)
    private func addNew(_ newController: AppViewController) {
        addChild(newController)
        newController.beginAppearanceTransition(true, animated: false)
        view.addSubview(newController.view)
        view.pinToBounds(newController.view)
        didMove(toParent: self)
        newController.endAppearanceTransition()
        
        currentController = newController
    }
    
    private func removeCurrentIfExists() {
        if let currentController = currentController {
            currentController.willMove(toParent: nil)
            currentController.beginAppearanceTransition(false, animated: false)
            currentController.view.removeFromSuperview()
            currentController.removeFromParent()
            currentController.endAppearanceTransition()
        }
    }
#elseif os(macOS)
    private func addNew(_ newController: AppViewController) {
        addChild(newController)
        view.addSubview(newController.view)
        view.pinToBounds(newController.view)
        
        currentController = newController
    }
    
    private func removeCurrentIfExists() {
        if let currentController = currentController {
            currentController.view.removeFromSuperview()
            currentController.removeFromParent()
        }
    }
#endif
}

public extension AppView {
    func pinToBounds(
        _ view: AppView,
        with insets: AppEdgeInsets = .zero
    ) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            
            // To keep contentEdgeInsets positive
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
        ])
    }
}

public extension AppEdgeInsets {
    static var zero: Self {
        return .init()
    }
}
