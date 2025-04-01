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
	var delegate: TextFieldCommunication? = nil
	
	var textHash: Int {
		storage.string.hashValue
	}
	
	var isEmpty: Bool {
		storage.string.isEmpty
	}
	
	var text: String {
		storage.string
	}

	
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
	
	func save() {
		delegate?.saveIfNeeded()
	}
	
	func makeStringPermutations(with array: [String]) -> [String] {
		var result: Set<String> = []
		array.enumerated().forEach { idx, value in
			result.insert(value)
			result.insert(array[idx...].reduce("", +))
		}
		
		return Array(result)
	}
	
	
	func setNewText(_ string: String) {
		let range = NSMakeRange(0, storage.string.count)
		storage.deleteCharacters(in: range)
		storage.insertOrAppend(at: 0, with: string)
		cursorIndex = 0
	}
	
	
}




