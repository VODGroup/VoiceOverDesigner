import Document

extension VODesignDocument {
    public override func makeWindowControllers() {
        WindowManager.shared
            .show(document: self)
    }
}
