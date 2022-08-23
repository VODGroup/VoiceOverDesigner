import Document

extension VODesignDocument {
    public override func makeWindowControllers() {
        WindowManager.shared
            .createNewDocumentWindow(document: self)
    }
}
