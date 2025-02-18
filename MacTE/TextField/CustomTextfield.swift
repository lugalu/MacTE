//Created by Lugalu on 17/02/25.

import AppKit

struct TextfieldConstants {
	static let backspaceCode = "deleteBackward:"
	static let deleteCode = "deleteForward:"
	
	static let moveLeft = "moveLeft:"
	static let moveRight = "moveRight:"
	static let moveUp = "moveUp:"
	static let moveDown = "moveDown:"
	
	static let codes: [String] = [
		backspaceCode,
		deleteCode,
		moveLeft,
		moveRight,
		moveUp,
		moveDown
	]

}

class CustomTextfield: NSView {
	override var acceptsFirstResponder: Bool { true }
	override var isFlipped: Bool { true }
	let storage = NSTextStorage()
	let container = NSTextContainer(size: .zero)
	let layoutManager = NSLayoutManager()
	let cursor = NSTextInsertionIndicator(frame: .zero)
	
	var cursorIndex = 0
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	override func becomeFirstResponder() -> Bool {
		cursor.displayMode = .automatic

		needsDisplay = true
		return super.becomeFirstResponder()
	}
	
	override func resignFirstResponder() -> Bool {
		cursor.displayMode = .hidden
		needsDisplay = true
		return super.resignFirstResponder()
	}
	
	func setup() {
		addSubview(cursor)
		cursor.displayMode = .automatic
		cursor.effectsViewInserter = { view in
			self.addSubview(view, positioned: .below, relativeTo: self.cursor)
		}
		cursor.automaticModeOptions = .showWhileTracking
		
		layoutManager.allowsNonContiguousLayout = true
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
		
		let glyphIndex = layoutManager.glyphIndexForCharacter(at: cursorIndex )

		let cursorRect = layoutManager.boundingRect(
			forGlyphRange: NSRange(location: glyphIndex, length: 0),
			in: container
		)

		cursor.frame = .init(
			origin: cursorRect.origin,
			size: cursorRect.size
		)
		cursor.needsDisplay = true
	}
	
	override func keyDown(with event: NSEvent) {
		self.inputContext?.handleEvent(event)
	}
	
	
}

extension CustomTextfield: NSTextInputClient {
	
	func insertText(_ string: Any, replacementRange: NSRange) {
		guard let string = string as? String else { return }
		
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
		let modifiers = makeModifiers()
		
		if modifiers.keys.contains(selector.description) {
			modifiers[selector.description]?()
			needsDisplay = true
			return
		}
	}
	
	func makeModifiers() -> [String: ()-> Void] {
		let functions: [() -> Void] = [
			backSpace,
			delete,
			moveLeft,
			moveRight,
			moveUp,
			moveDown
		]
		
		let result = TextfieldConstants.codes.enumerated().reduce(into: [String: () -> Void]()) { dict, value in
			dict[value.element] = functions[value.offset]
		}
		
		return result
	}
	
	func backSpace() {
		guard storage.length > 0 else { return }
	
		storage.deleteCharacters(in:.init(location: cursorIndex-1, length: 1))
		cursorIndex -= 1
	}
	
	func delete() {
		guard cursorIndex < storage.length else { return }
	
		storage.deleteCharacters(in: .init(location: cursorIndex, length: 1))
	}
	
	func moveLeft() {
		guard cursorIndex > 0 else { return }
		cursorIndex -= 1
	}
	
	func moveRight() {
		guard cursorIndex < storage.length else { return }
		cursorIndex += 1
	}
	
	func moveDown() {
		
	}
	
	func moveUp() {
		
	}
}


