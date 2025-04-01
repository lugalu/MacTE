# MacTE - MacOS Text Editor
This is a Proof of Concept (PoC) macOS app focused on creating a fairly basic text editor, the idealization of this project was to learn how text is handled under the hood within Apple's eco-system. this was acomplished by using the NSTextStorage, NSTextInputClient, NSTextContainer, NSLayoutManager, and NSTextInsertionIndicator.
![](https://i.imgur.com/F1ygNae.png)
## Features
- Basic text insertion and removal
- Basic Text selection with a _mouse_
- Undo/Redo for most operations

## WIP - Work in Progress
- Relationship between files in the outline view and the TextEditor
- Hashing to know if files did change, and saving changes to the system

## Missing
- Text selection with arrow keys, it didn't really strike as an different enough feature from the mouse to justify implementation in this PoC
- whe text is selected the arrow keys don't jump to the start or ende based on the context, they just clean the selection

## Building
There are no external dependencies so it should just be press run and experiment away, the code was made for macOS 15.1.
