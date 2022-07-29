# VoiceOverDesigner

<img width="500" alt="Screenshot of the application" src="https://user-images.githubusercontent.com/3120680/176926458-f46bad3b-4235-47ca-ab18-fa203ddb61d2.png">

A MacOS app that helps to design accessible apps in 3 stages:

### 1. Design

Designer uses VoiceOver Designer for macOS to layout accessibility over an app's screenshots. The designer can use VoiceOver Preview app for iPhone to hear the result.

VoiceOver Designer presents all possible instruments to designer and teaches them what a developer can and can't do with accessibility.

At the end the designer passes the document to developer.

It looks reasonable to integrate it directly to Figma, but it can be done later.

### 2. Development

A developer got the layout from the designer, can read it and understand what accessibility layout is expected from the visible UI.

### 3. Unit-testing (in feature release)

The app generates test-case for automatic testing of accessibility. In general we can start from AccessibilitySnapshot, but use it in different way: generate only readable text, we don't need a visual part of screenshot. I'll describe the idea In details at different topic, it's not goal of first release.

# What's next
- [How to launch](https://github.com/VODGroup/VoiceOverDesigner/wiki)
- [Join to discussions](https://github.com/VODGroup/VoiceOverDesigner/discussions)

