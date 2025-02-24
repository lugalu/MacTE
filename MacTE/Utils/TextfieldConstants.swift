//Created by Lugalu on 24/02/25.

import Foundation

struct TextfieldConstants {
	private init(){}
	
	static let padding: CGFloat = 4
	
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
	// deleteBackwardByDecomposingPreviousCharacter = ctr + backspace // future impl.
	
	//MARK: Command Dict
	static let commands: [String: Command] = [
		backspace: Backspace(),
		delete: Delete(),
		wordBackspace: WordBackspace(),
		wordDelete: WordDelete(),
		deleteToBeginningOfLine: DeleteToBegginingOfLine(),
		moveLeft: MoveLeft(),
		moveRight: MoveRight(),
		moveUp: MoveUp(),
		moveDown: MoveDown(),
		addNewLine: NewLine()
	]
	
}
