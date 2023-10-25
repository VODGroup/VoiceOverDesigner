//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 21.08.2021.
//

import AppKit

public typealias ViewController = NSViewController

public protocol StateProtocol: Equatable {
    static var `default`: Self { get }
}

open class StateViewController<State>: ViewController
where State: StateProtocol {
    
    open var stateFactory: ((State) -> ViewController)!

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        addController(for: state)
    }
    
    
    open override func loadView() {
        view = NSView()
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
    
    // MARK: Controller managment
    
    public private(set) weak var currentController: ViewController?
    
    private func addController(for state: State) {
        addNew(stateFactory(state))
    }
    
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
}

public extension NSView {
    func pinToBounds(
        _ view: NSView,
        with insets: NSEdgeInsets = .zero
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

public extension NSEdgeInsets {
    static var zero: Self {
        return .init()
    }
}
