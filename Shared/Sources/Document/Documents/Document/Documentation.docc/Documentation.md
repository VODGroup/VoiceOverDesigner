# ``Document``

File structure that converts to in-memory ``Artboard``. Main goal – persist user data and keep it safe. In feature we can integrate Figma's file structure

## Overview

Document package manages persistence by subclassing NSDocument in VODesignDocument

## Document versioning

We have 3 version formats
* beta-release of first users
* frame version of first release with single-page support
* artboard that supports multiple frames and connections between them

Migration consists from two steps:

- **Read old structure in memory**: the format in folder isn't changed during reading, but domain logic is independent according to file's structure. ``VODesignDocument/read(from:ofType:)``
- **Update document's structure during writing**: migration happens during writing process. During migration you had to update all relatives paths, images for e.g. ``VODesignDocument/fileWrapper(ofType:)``

Document structure depends on `FileWrapper` abstraction and not contains absolute paths. 

> Important: To properly keep cache unchanged you should use ``VODesignDocument/documentWrapper`` gathered from reading. 

> Tip: Keep snapshot of every version and write unit-tests for all possible actions and bugs during migration.


## Topics

### Document format

- ``VODesignDocumentProtocol``
- ``VODesignDocument``
- ``DocumentPresenter``
- ``containerId``
- ``defaultFrameName``
- ``iCloudContainer``
- ``uti``
- ``vodesign``
- ``FrameInfo``

- ``ThumbnailDocument``

### Decoding
- ``DecodableDefault``
- ``Storage``
- ``ImageLocationDto``
- ``FolderName``
- ``DecodableDefaultSource``

### Data transfer objets
- ``Frame``
- ``A11yContainer``
- ``A11yDescription``
- ``A11yCustomActions``
- ``A11yCustomDescription``
- ``A11yCustomDescriptions``
- ``A11yTraits``
- ``AdjustableOptions``
- ``InstantiatableContainer``

### Artboard:
- ``Artboard``
- ``ArtboardElement``
- ``ArtboardContainer``
- ``ArtboardElementCast``
- ``ArtboardType``

### Image loading

Image loader can read any type of locations: relative, remote, temporary cache

- ``ImageLoader``
- ``ImageLocation``
- ``ImageLoading``
- ``DummyImageLoader``

## Preview

- ``PreviewSourceProtocol``
- ``VODesignDocumentPresentation``
