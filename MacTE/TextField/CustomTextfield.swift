//Created by Lugalu on 17/02/25.

import AppKit


struct UndoData {
	let startCursorPos: Int
	let deletedString: String
}

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
