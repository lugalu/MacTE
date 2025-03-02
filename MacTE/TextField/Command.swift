//Created by Lugalu on 24/02/25.

import AppKit

protocol Command {
	func execute(_ context: TextfieldContext)
	func execute(_ context: TextfieldContext, _ inserting: String?)
}

protocol Undoable {
	var commandContext: CommandContext? { get }
	func undo(_ context: CommandContext)
}

extension Undoable {
	func makeCommandContext(_ context: TextfieldContext, _ string: String?) -> CommandContext {
		return CommandContext(
			originalContext: context,
			location: context.cursorIndex,
			modification: string
		)
	}
}

struct CommandContext {
	var originalContext: TextfieldContext
	var location: Int
	var modification: String?
}

protocol TextfieldContext: AnyObject {
	var cursorIndex: Int { get set }
	var storage: NSTextStorage { get }
	var container: NSTextContainer { get }
	var layoutManager: NSLayoutManager { get }	
}


class BaseCommand: Command {
	func execute(_ context: any TextfieldContext) {
		
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		
	}
	
}

class CommandStack {
	typealias Undo = (Undoable & Command)
	static let shared = CommandStack()
	
	var undoStack: [Undo] = []
	var redoStack: [Undo] = []
	
	private init(){}
	
	func push(command: Undo) {
		undoStack.append(command)
	}
	
	func undo(){
		
	}
	
	func redo(){
		
	}
	
}

