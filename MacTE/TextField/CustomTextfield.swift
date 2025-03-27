//Created by Lugalu on 17/02/25.

import AppKit


struct DestructiveUndoData {
	let startCursorPos: Int
	let deletedString: String
}

struct ConstructiveUndoData {
	let cursorPosition: Int
	let insertedString: Int
	let removedString: DestructiveUndoData?
}

/*
 TODO: Check if the Base OP, UNDO, and REDO were a success if so we append to the stacks!

 TODO: list of following for UNDO
 - Cut, Delete, Backspace, WordBackspace, WordDelete, DeleteBeggining of line we reinsert the text, should be easy
	- can be achieved by creating a struct that stores the cursor position and the removed string, can be reutilized by all
 - Insert, Paste, NewLine
	- delete the inserted text, basically the same as above
 - Insert Past, Newline with Selection,
  - First we delete the insert then reinsert the previous text, the struct from above can contain the details for this OP, we just change context based on the selection!
 
 TODO: clean REDO func as a requirement after implementing all ops
 TODO: figure out how to pipe to REDO
 */


class CustomTextfield: NSView, TextfieldContext {
	override var acceptsFirstResponder: Bool { true }
	override var isFlipped: Bool { true }
	
	let storage = NSTextStorage()
	let container = NSTextContainer(size: .zero)
	let layoutManager = NSLayoutManager()
	let cursor = NSTextInsertionIndicator(frame: .zero)
	
	var selectionRange: NSRange? = nil
	var selectionPath: NSBezierPath? = nil

	
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
		cursor.setFrameSize(.init(width: 100, height: cursor.frame.height))
		
		drawSelectionBox()
	}
	
	func drawSelectionBox() {
		guard let selectionRange, selectionRange.length != 0 else {
			NSColor.clear.setFill()
			selectionPath?.fill()
			selectionPath = nil
			return
		}
		
		var rect = layoutManager
			.boundingRect(forGlyphRange: selectionRange, in: container)
		rect.origin = rect
			.origin
			.applying(
				.init(translationX: TextfieldConstants.padding,
					  y: TextfieldConstants.padding))
		
		NSColor.selectedTextBackgroundColor
			.withAlphaComponent(0.3)
			.setFill()
		selectionPath = NSBezierPath(rect: rect)
		selectionPath?.fill()
	
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
			
			pushCommandToStack(command: command(self))
			break
		}
	}
	
	func makeStringPermutations(with array: [String]) -> [String] {
		var result: Set<String> = []
		
		array.enumerated().forEach { idx, value in
			result.insert(value)
			result.insert(array[idx...].reduce("", +))
		}
		
		return Array(result)
	}
		
	override func mouseDown(with event: NSEvent) {
		let idx = characterIndex(
			for: windowToPoint(with: event.locationInWindow))
		
		self.cursorIndex = idx
		selectionRange = nil
	}
	
	func windowToPoint(with event: NSPoint) -> NSPoint {
		var point = convert(event, from: nil)
		point.y = max(0, point.y - TextfieldConstants.padding)
		point.x = max(0, point.x - TextfieldConstants.padding)
		
		return point
	}
	
	override func mouseDragged(with event: NSEvent) {
		let idx = characterIndex(
			for: windowToPoint(with: event.locationInWindow))

		selectionRange = NSMakeRange(
			min(idx, cursorIndex),
			abs(idx - cursorIndex)
		)

		needsDisplay = true
	}
}

extension CustomTextfield: NSTextInputClient {
	
	func insertText(_ string: Any, replacementRange: NSRange) {
		guard let string = string as? String else {
			return
		}
		
		_ = deleteSelection(self)
		
		let attributedString = NSAttributedString(string: string)
		if replacementRange.location != NSNotFound {
			storage.replaceCharacters(in: replacementRange,
								   with: attributedString
			)
			return
		}
		
		storage.insert(attributedString, at: cursorIndex)
		cursorIndex += string.count
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
		
		var idx = layoutManager
			.characterIndex(
				for: point,
				in: container,
				fractionOfDistanceBetweenInsertionPoints: pointer
			)
		
		idx += pointer.pointee >= 0.5 ? 1 : 0
		
		return idx
	}
	
	override func doCommand(by selector: Selector) {
		let commandKey = selector.description
		guard let command = TextfieldConstants.commands[commandKey] else {
			return
		}
		
		pushCommandToStack(command: command(self))
	}
	
	func pushCommandToStack(command: Command) {
		CommandStack.shared.push(command: command, with: self)
	}
	
	
	//Unused
	func setMarkedText(
		_ string: Any,
		selectedRange: NSRange,
		replacementRange: NSRange
	) {}

	
	func unmarkText() {}
	
	func selectedRange() -> NSRange {
		return .init()
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
}

