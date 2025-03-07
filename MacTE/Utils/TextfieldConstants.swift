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
		paste : {
			//TODO: Implement
			return NewLine()
		},
		copy : {
			// TODO: Implement
			return NewLine()
		},
		cut : {
			//TODO: Implement
			return NewLine()
		},
		undo: {
			//TODO: implement
			CommandStack.shared.undo()
			return NewLine()
		},
		redo: {
			//TODO: Implement
			CommandStack.shared.redo()
			return NewLine()
		}
	]
	
}
