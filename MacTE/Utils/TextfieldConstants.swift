//Created by Lugalu on 24/02/25.

import Cocoa

struct TextfieldConstants {
	private init(){}
	
	static let padding: CGFloat = 8
	private typealias System = NSEvent.ModifierFlags
	
	//MARK: KeyCodes
	//Delete
	static let backspace = "deleteBackward:"
	static let delete = "deleteForward:"
	static let wordBackspace = "deleteWordBackward:"
	static let wordDelete = "deleteWordForward:"
	static let deleteToBeginningOfLine = "deleteToBeginningOfLine:"
	
	//Move
	static let moveLeft = "moveLeft:"
	static let moveRight = "moveRight:"
	static let moveUp = "moveUp:"
	static let moveDown = "moveDown:"
	
	//Insert
	static let addNewLine = "insertNewline:"
	static let paste = System.getName(for: .command) + "v"
	static let copy = System.getName(for: .command) + "c"
	static let cut = System.getName(for: .command) + "x"
	static let undo = System.getName(for: .command) + "z"
	static let redo = System.getName(for: .command) +
					  System.getName(for: .shift) +
					  "z"
	// deleteBackwardByDecomposingPreviousCharacter = ctr + backspace // future impl.
	// move whole word to left or right
	
	//MARK: Command Dict
	static let commands: [String: (_: TextfieldContext?) -> Command] = [
		backspace: { _ in Backspace() },
		delete: { _ in Delete() } ,
		wordBackspace: { _ in WordBackspace() },
		wordDelete: { _ in WordDelete() },
		deleteToBeginningOfLine: { _ in DeleteToBegginingOfLine() },
		moveLeft: { _ in MoveLeft() },
		moveRight: { _ in MoveRight() },
		moveUp: { _ in MoveUp() },
		moveDown: { _ in MoveDown() },
		addNewLine: { _ in NewLine() },
		paste : { _ in Paste() },
		copy : { _ in Copy() },
		cut : { _ in Cut() },
		undo: { context in
			guard let context else { return NoOperation.shared }
			CommandStack.shared.undo(with: context)
			return NoOperation.shared
		},
		redo: { context in
			guard let context else { return NoOperation.shared }
			CommandStack.shared.redo(with: context)
			return NoOperation.shared
		}
	]
	
}

class NoOperation: Command {
	static let shared = NoOperation()
	
	
	private init() {}
	
	func execute(_ context: any TextfieldContext) {
		return
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		return
	}
}
