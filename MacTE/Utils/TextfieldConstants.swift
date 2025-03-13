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
	static let commands: [String: () -> Command] = [
		backspace: { Backspace() },
		delete: { Delete() } ,
		wordBackspace: { WordBackspace() },
		wordDelete: { WordDelete() },
		deleteToBeginningOfLine: { DeleteToBegginingOfLine() },
		moveLeft: { MoveLeft() },
		moveRight: { MoveRight() },
		moveUp: { MoveUp() },
		moveDown: { MoveDown() },
		addNewLine: { NewLine() },
		paste : { return Paste() },
		copy : { return Copy() },
		cut : { return Cut() },
		undo: {
			CommandStack.shared.undo()
			return NoOperation.shared
		},
		redo: {
			CommandStack.shared.redo()
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
