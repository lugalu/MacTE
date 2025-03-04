//Created by Lugalu on 17/02/25.

import AppKit

class TextSelectionHandler {
	var head: Int
	var anchor: Int
	var markedRange: NSRange? = nil
	
	init(head: Int, anchor: Int? = nil) {
		self.head = head
		self.anchor = anchor ?? head
	}
	
	var range: NSRange {
		NSMakeRange(min(head, anchor), abs(head - anchor))
	}
	
	func getValidRange(for eventRange: NSRange) -> NSRange {
		guard eventRange.location != NSNotFound else {
			return markedRange ?? range
		}
		return eventRange
	}
	
	func invalidate( with newHead: Int) {
		head = newHead
		anchor = newHead
		markedRange = nil
	}
}

class CustomTextfield: NSView, TextfieldContext {
	override var acceptsFirstResponder: Bool { true }
	override var isFlipped: Bool { true }
	
	let storage = NSTextStorage()
	let container = NSTextContainer(size: .zero)
	let layoutManager = NSLayoutManager()
	let cursor = NSTextInsertionIndicator(frame: .zero)
	let selectionHandler = TextSelectionHandler(head: 0)
	
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
	
	func setup() {
		addSubview(cursor)
		cursor.displayMode = .automatic
		cursor.effectsViewInserter = { view in
			self.addSubview(view, positioned: .above, relativeTo: self.cursor)
		}
		cursor.automaticModeOptions = .showWhileTracking
		
		container.widthTracksTextView = true
		container.lineFragmentPadding = 0.2
		
		storage.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
		
		container.layoutManager = layoutManager
		layoutManager.addTextContainer(container)
		storage.addLayoutManager(layoutManager)
		
		cursor.frame = getCursorRect()
	}
	
	func getCursorRect() -> NSRect {
		let glyphIndex = layoutManager.glyphIndexForCharacter(at: cursorIndex)
		let padding = TextfieldConstants.padding

		return layoutManager.boundingRect(
			forGlyphRange: NSRange(location: glyphIndex, length: 0),
			in: container
		).applying(.init(translationX: padding, y: padding))
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
		
		cursor.setFrameOrigin(getCursorRect().origin)
		
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
	
	override func keyDown(with event: NSEvent) {
		self.inputContext?.handleEvent(event)
		handleCustomEvents(event)
		
	}
	
	func handleCustomEvents(_ event: NSEvent) {
		let eventModifiers = event.modifierFlags.getNames()
		guard !eventModifiers.isEmpty,
			  let key = event.charactersIgnoringModifiers?.lowercased() else {
			return
		}

		let commandPossibilities = makeStringPermutations(with: eventModifiers)
			.sorted { $0.count > $1.count }

		for cmd in commandPossibilities {
			guard let command = TextfieldConstants.commands[cmd + key] else {
				continue
			}
			
			command().execute(self)
			break
		}
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
		
		if replacementRange.location != NSNotFound {
			storage.replaceCharacters(in: replacementRange,
								   with: attributedString)
			return
		}
		
		
		storage.insert(attributedString, at: cursorIndex)
		cursorIndex += string.count
		selectionHandler.invalidate(with: cursorIndex)
		
	}
	
	func setMarkedText(
		_ string: Any,
		selectedRange: NSRange,
		replacementRange: NSRange
	) {
		guard let string = string as? String else {
			return
		}
		
		let replacementRange = selectionHandler
			.getValidRange(for: replacementRange)
		
		if string.count == 0 {
			storage.deleteCharacters(in: replacementRange)
			unmarkText()
			cursorIndex = replacementRange.lowerBound
		}else {
			selectionHandler.markedRange = NSMakeRange(
				replacementRange.location,
				string.count
			)
			storage
				.replaceCharacters(in: replacementRange,
					with: string
				)
			cursorIndex = NSMaxRange(replacementRange) + 1
		}
		
		selectionHandler.head = replacementRange.location +
		selectedRange.location
		
		selectionHandler.anchor = selectionHandler.head + selectedRange.length
		
		needsDisplay = true
	}

	
	func unmarkText() {
		selectionHandler.markedRange = nil
		needsDisplay = true
	}
	
	func selectedRange() -> NSRange {
		return selectionHandler.range
	}
	
	func markedRange() -> NSRange {
		return selectionHandler.markedRange ?? NSMakeRange(NSNotFound, 0)
	}
	
	func hasMarkedText() -> Bool {
		return selectionHandler.markedRange != nil
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

