import Foundation
import Document

public class ContainerSettingsPresenter {
    public init(
        container: A11yContainer,
        delegate: SettingsDelegate
    ) {
        self.container = container
        self.delegate = delegate
    }
    
    public var container: A11yContainer
    public weak var delegate: SettingsDelegate?
}

extension ContainerSettingsPresenter: LabelDelegate {
    func updateLabel(to text: String) {
        container.label = text
        delegate?.updateValue()
//        ui?.updateTitle()
    }
}
