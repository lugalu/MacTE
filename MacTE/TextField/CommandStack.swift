//Created by Lugalu on 27/03/25.

import AppKit

class CommandStack {
	typealias Undo = (Undoable & Command)
	static let shared = CommandStack()
	
	var undoStack: [Undo] = []
	var redoStack: [Undo] = []
	
	private init(){}
	
	func push(command: Command, with context: TextfieldContext, isNew: Bool = true) {
		guard !(command is NoOperation) else { return }
		
		command.execute(context)

		if isNew { redoStack.removeAll() }
		if command is Undoable {
			undoStack.append(command as! Undo)
		}
	}
	
	func push(command: Command, with context: TextfieldContext, string: String?, isNew: Bool = true) {
		guard !(command is NoOperation) else { return }
		
		command.execute(context, string)

		if isNew { redoStack.removeAll() }
		if command is Undoable {
			undoStack.append(command as! Undo)
		}
	}
	
	
	func undo(with context: TextfieldContext){
		guard !undoStack.isEmpty else { return }
		let command = undoStack.removeLast()
		command.undo(context)
		redoStack.append(command)
	}
	
	func redo(with context: TextfieldContext) {
		guard !redoStack.isEmpty else { return }
		let command = redoStack.removeLast()
		
		if let command = command as? Insert {
			push(
				command: command,
				with: context,
				string: command.commandContext?.deletedString,
				isNew: false
			)
			return
		}
		
		push(command: command, with: context, isNew: false)
	}
	
	func clear() {
		redoStack.removeAll()
		undoStack.removeAll()
	}
	
}
