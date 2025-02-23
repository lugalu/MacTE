//Created by Lugalu on 17/02/25.

import AppKit
import Foundation
struct TextfieldConstants {
	static let padding: CGFloat = 4
	
	//KeyCodes
	static let backspace = "deleteBackward:"
	static let delete = "deleteForward:"
	static let wordBackspace = "deleteWordBackward:"
	static let wordDelete = "deleteWordForward:"
	static let deleteToBeginningOfLine = "deleteToBeginningOfLine:"
	
	
	static let moveLeft = "moveLeft:"
	static let moveRight = "moveRight:"
	static let moveUp = "moveUp:"
	static let moveDown = "moveDown:"
	
	
	static let addNewLine = "insertNewline:"
	/*
	 deleteBackwardByDecomposingPreviousCharacter = ctr + backspace // future impl.
	 */
	
	static let codes: [String] = [
		backspace,
		delete,
		wordBackspace,
		wordDelete,
		deleteToBeginningOfLine,
		moveLeft,
		moveRight,
		moveUp,
		moveDown,
		addNewLine
	]
	
}

class CustomTextfield: NSView {
	override var acceptsFirstResponder: Bool { true }
	override var isFlipped: Bool { true }
	let storage = NSTextStorage()
	let container = NSTextContainer(size: .zero)
	let layoutManager = NSLayoutManager()
	let cursor = NSTextInsertionIndicator(frame: .zero)
	
	var modifiers: [String: () -> Void] = [:]
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
		
		container.widthTracksTextView = true
		container.lineFragmentPadding = 0.2
		
		storage.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
		
		layoutManager.addTextContainer(container)
		storage.addLayoutManager(layoutManager)
		
		self.modifiers = makeModifiers()
	}
	
	func makeModifiers() -> [String: ()-> Void] {
		let functions: [() -> Void] = [
			backSpace,
			delete,
			wordBackspace,
			wordDelete,
			deleteToBegginingOfLine,
			moveLeft,
			moveRight,
			moveUp,
			moveDown,
			addNewLine
		]
		
		let result = TextfieldConstants.codes
			.enumerated()
			.reduce(into: [String: () -> Void]()) { dict, value in
				dict[value.element] = functions[value.offset]
			}
		
		return result
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
		print(selector.description)
		
		if let function = modifiers[selector.description] {
			function()
			needsDisplay = true
			return
		}
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
	
	func wordDelete() {
		guard storage.length > 0, cursorIndex < storage.length else { return }
		let string = storage.string
		let lowerBound = string.index(string.startIndex, offsetBy: cursorIndex)
		let stringRange = lowerBound...
		
		guard let word = string[stringRange]
			.components(separatedBy: .whitespacesAndNewlines)
			.first,
			  !word.isEmpty
		else {
			return
		}
		
		let difference = cursorIndex + word.count-1
		let deletionRange = NSRange(cursorIndex...difference)
		
		storage.deleteCharacters(in: deletionRange)
	}
	
	func wordBackspace() {
		guard storage.length > 0, cursorIndex <= storage.length else { return }
		let string = storage.string
		let upperBound = string.index(string.startIndex,
									  offsetBy: cursorIndex - 1)
		let range = string.startIndex...upperBound
		
		guard let word = string[range]
			.components(separatedBy: .whitespacesAndNewlines)
			.last,
			  !word.isEmpty
		else { return }
		
		let difference = cursorIndex - word.count
		let deletionRange = NSRange(difference...cursorIndex-1)
		
		cursorIndex = difference
		storage.deleteCharacters(in: deletionRange)
	}
	
	func deleteToBegginingOfLine() {
		guard cursorIndex <= storage.length else { return }
		let string = storage.string
		
		let upperBound = string.index(string.startIndex,
									  offsetBy: cursorIndex - 1)
		let range = string.startIndex...upperBound
		
		let idx = string[range].lastIndex(where: { $0 == "\n" }) ?? string.startIndex
		
		let distance = string.distance(
			from: string.startIndex,
			to: string.index(after: idx)
		)
		
		let lenght = cursorIndex - distance
		
		storage.deleteCharacters(in: .init(location: distance, length: lenght))
		
		cursorIndex -= lenght
		cursorIndex = max(abs(cursorIndex), 0)
		
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
		guard storage.length > 0 else { return }
		
		let numberOfGlyphs = layoutManager.numberOfGlyphs
		let lineCount = lineNumber(for: numberOfGlyphs)
		let cursorLine = lineNumber(for: cursorIndex)
		
		guard cursorLine < lineCount else { return }
		
		var cursorRange: NSRange? = nil
		layoutManager
			.enumerateLineFragments(forGlyphRange: NSRange(0...numberOfGlyphs)) { [weak self] (_,_,_, range, stop) in
				guard let self else { return }
				
				if let validRange = cursorRange {
					let difference = self.cursorIndex - validRange.lowerBound
					let newCursor = range.lowerBound + difference
					self.cursorIndex = clamp(
						range.lowerBound,
						value: newCursor,
						maxValue: range.upperBound
					)
					cursorRange = nil
					stop.pointee = true
					return
				}
				
				if range.contains(self.cursorIndex) {
					cursorRange = range
				}
				
			}
	}
	
	func moveUp() {
		guard cursorIndex > 0, cursorIndex <= storage.length else { return }
		
		let numberOfGlyphs = layoutManager.numberOfGlyphs
		let cursorLine = lineNumber(for: cursorIndex)
		
		guard cursorLine > 1 || lineNumber(for: cursorIndex + 1) > 1 else { return }
		
		var previousLine:NSRange? = nil
		layoutManager
			.enumerateLineFragments(forGlyphRange: NSRange(0...numberOfGlyphs)) { [weak self] (_,_,_, range, stop) in
				guard let self else { return }
				
				defer {
					previousLine = range
				}
				
				// for some reason contains wasn't checking it's upperBound so the edgeCase is checked on the if
				if (range.lowerBound...range.upperBound)
					.contains(self.cursorIndex) {
					
					guard let previousLine else {
						return
					}
					
					let difference = self.cursorIndex - range.lowerBound
					let newCursor = previousLine.lowerBound + difference
					let lastLineEnd = previousLine.upperBound - 1
					
					self.cursorIndex = clamp(previousLine.lowerBound,
											 value: newCursor,
											 maxValue: lastLineEnd
					)
					stop.pointee = true
					return
				}
			}
	}
	
	func lineNumber(for target: Int) -> Int {
		var numberOfLines = 0
		
		var index = 0
		
		let range: NSRangePointer = .allocate(capacity: 4)
		
		while index < target {
			layoutManager.lineFragmentRect(forGlyphAt: index,
										   effectiveRange:  range)
			index = NSMaxRange(range.pointee)
			numberOfLines += 1
		}
		
		return numberOfLines
	}
	
	
	func addNewLine() {
		let newLine = NSAttributedString(string: "\n")
		
		if cursorIndex <= storage.length {
			storage.insert(newLine, at: cursorIndex)
		}else {
			storage.append(newLine)
		}
		
		cursorIndex += 1
	}
}

