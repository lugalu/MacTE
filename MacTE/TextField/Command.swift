//Created by Lugalu on 24/02/25.

import AppKit

protocol Command {
	func execute(_ context: TextfieldContext)
	func execute(_ context: TextfieldContext, _ inserting: String?)
}

protocol Undoable {
	func undo(_ context: TextfieldContext)
	func redo(_ context: TextfieldContext)
}

protocol TextfieldContext: AnyObject {
	var cursorIndex: Int { get set }
	var cursor: NSTextInsertionIndicator { get }
	var storage: NSTextStorage { get }
	var container: NSTextContainer { get }
	var layoutManager: NSLayoutManager { get }
	var selectionRange: NSRange? { get set }
	var selectionPath: NSBezierPath? { get }
}

class CommandStack {
	typealias Undo = (Undoable & Command)
	static let shared = CommandStack()
	
	var undoStack: [Undo] = []
	var redoStack: [Undo] = []
	
	private init(){}
	
	func push(command: Command, with context: TextfieldContext, isNew: Bool = true) {
		guard !(command is NoOperation) else { return }
		command.execute(context)

		if isNew { redoStack = [] }
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
		push(command: command, with: context, isNew: false)
	}
	
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
