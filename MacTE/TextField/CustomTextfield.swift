//Created by Lugalu on 17/02/25.

import AppKit

class CustomTextfield: NSView, TextfieldContext {
	override var acceptsFirstResponder: Bool { true }
	override var isFlipped: Bool { true }
	
	let storage = NSTextStorage()
	let container = NSTextContainer(size: .zero)
	let layoutManager = NSLayoutManager()
	let cursor = NSTextInsertionIndicator(frame: .zero)
	
	var cursorIndex = 0 {
		didSet {
			needsDisplay = true
		}
	}
	
	
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
		
		container.widthTracksTextView = true
		container.lineFragmentPadding = 0.2
		
		storage.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
		
		container.layoutManager = layoutManager
		layoutManager.addTextContainer(container)
		storage.addLayoutManager(layoutManager)
	}
	
	
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		NSColor.textBackgroundColor.setFill()
		dirtyRect.fill()
		storage.foregroundColor = NSColor.textColor
		
		let padding = TextfieldConstants.padding
		
		container.size = bounds.insetBy(dx: padding, dy: padding).size
		
		let glyphs = layoutManager.glyphRange(forBoundingRect: bounds,
											  in: container)
		
		let paddingPoint = CGPoint(x: padding, y: padding)
		
		layoutManager.drawBackground(forGlyphRange: glyphs, at: paddingPoint)
		layoutManager.drawGlyphs(forGlyphRange: glyphs, at: paddingPoint)
		layoutManager.showsControlCharacters = true
		
		let glyphIndex = layoutManager.glyphIndexForCharacter(at: cursorIndex)
		let cursorRect = layoutManager.boundingRect(
			forGlyphRange: NSRange(location: glyphIndex, length: 0),
			in: container
		)
		
		cursor.frame = .init(
			origin: cursorRect.origin.applying(
				.init(translationX: padding, y: padding)),
			size: cursorRect.size
		)
		cursor.needsDisplay = true
	}
	
	override func keyDown(with event: NSEvent) {
		self.inputContext?.handleEvent(event)
	}
	
	override func mouseDown(with event: NSEvent) {
		var point = convert(event.locationInWindow, from: nil)
		point.y = max(0, point.y - TextfieldConstants.padding)
		point.x = max(0, point.x - TextfieldConstants.padding)
		
		let idx = characterIndex(for: point)
		self.cursorIndex = idx
		
	}
	
}

extension CustomTextfield: NSTextInputClient {
	
	func insertText(_ string: Any, replacementRange: NSRange) {
		guard let string = string as? String else {
			print("doesn't work")
			return
		}
		
		let attributedString = NSAttributedString(string: string)
		storage.insert(attributedString, at: cursorIndex)
		
		cursorIndex += string.count
	}
	
	// trigerred by '
	func setMarkedText(
		_ string: Any,
		selectedRange: NSRange,
		replacementRange: NSRange
	) {
		
		print("hm, \(string)", selectedRange, replacementRange)
	}
	
	func unmarkText() {
		print("unmark?")
	}
	
	func selectedRange() -> NSRange {
		print("selection")
		return .init(location: cursorIndex, length: 0)
	}
	
	func markedRange() -> NSRange {
		print("markedRange")
		return .init()
	}
	
	//called everytime a key is pressed
	func hasMarkedText() -> Bool {
		return false
	}
	
	func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
		print("attributedString")
		return nil
	}
	
	func validAttributesForMarkedText() -> [NSAttributedString.Key] {
		return []
	}
	
	func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
		return layoutManager
			.lineFragmentRect(
				forGlyphAt: range.lowerBound,
				effectiveRange: actualRange
			)
	}
	
	func characterIndex(for point: NSPoint) -> Int {
		
		let pointer: UnsafeMutablePointer<CGFloat> = .allocate(capacity: 1)
		pointer.pointee = 1
		defer{
			pointer.deallocate()
		}
		
		return  layoutManager
			.characterIndex(
				for: point,
				in: container,
				fractionOfDistanceBetweenInsertionPoints: nil
			)
	}
	
	override func doCommand(by selector: Selector) {
		let commandKey = selector.description
		print(commandKey)
		if let command = TextfieldConstants.commands[commandKey] {
			command().execute(self)
			return
		}
	}
}

