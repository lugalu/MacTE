//Created by Lugalu on 17/02/25.

import AppKit

struct TextfieldConstants {
	static let backspaceCode = "\u{7F}"
	static let deleteCode = "\u{8}"
}

class CustomTextfield: NSView {
	override var acceptsFirstResponder: Bool { true }
	override var isFlipped: Bool { true }
	let storage = NSTextStorage()
	let container = NSTextContainer(size: .zero)
	let layoutManager = NSLayoutManager()
	let cursor = NSTextInsertionIndicator()
	
	var cursorIndex = 0
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	func setup() {
		self.addSubview(cursor)
		cursor.displayMode = .automatic
		
		container.widthTracksTextView = true
		container.lineFragmentPadding = 0.2
		
		layoutManager.addTextContainer(container)
		storage.addLayoutManager(layoutManager)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		NSColor.textBackgroundColor.setFill()
		dirtyRect.fill()
		storage.foregroundColor = NSColor.textColor
		
		let glyphs = layoutManager.glyphRange(forBoundingRect: bounds, in: container)
		layoutManager.drawBackground(forGlyphRange: glyphs, at: .zero)
		layoutManager.drawGlyphs(forGlyphRange: glyphs, at: .zero)
		layoutManager.showsControlCharacters = true
	}
	
	override func keyDown(with event: NSEvent) {
		self.inputContext?.handleEvent(event)
	}
}

extension CustomTextfield: NSTextInputClient {
	
	func insertText(_ string: Any, replacementRange: NSRange) {
		guard let string = string as? String else { return }
		
		//Modifier keys
		
		
		
		if replacementRange.upperBound >= storage.length {
			storage.append(.init(string: string))
		}else {
			storage.replaceCharacters(in: replacementRange, with: string)
		}
		
		
		
		cursorIndex += string.count
		needsDisplay = true
	
	}

	func setMarkedText(
		_ string: Any,
		selectedRange: NSRange,
		replacementRange: NSRange
	) {
		print("hm")
	}

	func unmarkText() {
	
	}

	func selectedRange() -> NSRange {
		return .init(location: cursorIndex, length: 0)
	}

	func markedRange() -> NSRange {
		return .init()
	}

	func hasMarkedText() -> Bool {
		return false
	}

	func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
		return nil
	}

	func validAttributesForMarkedText() -> [NSAttributedString.Key] {
		return []
	}

	func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
		return .zero
	}

	func characterIndex(for point: NSPoint) -> Int {
		return 0
	}

	override func doCommand(by selector: Selector) {
		print("handle commands!")
	}
	
}


