# VoiceOverDesigner

VoiceOver Designer helps to design accessible apps.

The process will have 3 stages:

### 1. Design

Designer use VoiceOver Designer for macOS to layout accessibility over an app's screenshots. The designer can use VoiceOver Preview app for iPhone to hear the result.

VoiceOver Designer presents all possible instruments to designer and teachs them what a develop can and can't do with accessibility.

At the end the designer passes the document to developer.

It looks reasonable to integrate it directly to Figma, but it can be done later.

### 2. Development

A developer got the layout from the designer, can read it and understand what accessibility layout is expected from the visible UI.

### 3. Unit-testing (in feature release)

The app generates test-case for automatic testing of accessibility. In general we can start from AccessibilitySnapshot, but use it in different way: generate only readable text, we don't need a visual part of screenshot. I'll describe the idea In details at different topic, it's not goal of first release.


[Wiki](https://github.com/akaDuality/VoiceOverDesigner/wiki)
