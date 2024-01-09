//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 21.08.2021.
//

#if os(iOS)
import UIKit
public typealias ViewController = UIViewController
public typealias View = UIView
public typealias EdgeInsets = UIEdgeInsets
#elseif os(macOS)
import AppKit
public typealias ViewController = NSViewController
public typealias View = NSView
public typealias EdgeInsets = NSEdgeInsets
#endif

public protocol StateProtocol: Equatable {
    static var `default`: Self { get }
}

open class StateViewController<State>: ViewController
where State: StateProtocol {
    
    open var stateFactory: ((State) -> ViewController)!

    open var shouldSetDefaultControllerOnViewDidLoad: Bool = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    
        if shouldSetDefaultControllerOnViewDidLoad {
            addController(for: state)
        }
    }
    
    
    open override func loadView() {
        view = View()
    }
    
    // MARK: State
    
    open var state: State = .default {
        didSet {
            let isChanged = state != oldValue
            if isChanged {
                removeCurrentIfExists()
                addController(for: state)
            }
        }
    }
    
    // MARK: Controller management
    
    public private(set) weak var currentController: ViewController?
    
    private func addController(for state: State) {
        addNew(stateFactory(state))
    }
#if os(iOS)
    private func addNew(_ newController: ViewController) {
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
    private func addNew(_ newController: ViewController) {
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

public extension View {
    func pinToBounds(
        _ view: View,
        with insets: EdgeInsets = .zero
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

public extension EdgeInsets {
    static var zero: Self {
        return .init()
    }
}
