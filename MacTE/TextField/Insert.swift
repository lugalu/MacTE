//Created by Lugalu on 24/02/25.

import AppKit

class BaseConstructiveBehaviour: Undoable {
	var commandContext: DestructiveUndoData? = nil
	
	func undo(_ context: TextfieldContext) {
		guard let commandContext else { return }
		context.selectionRange = nil
		ExecuteDestructiveUndo(commandContext: commandContext, context: context)
		
		self.commandContext = DestructiveUndoData(
			startCursorPos: context.cursorIndex,
			deletedString: commandContext.deletedString
		)
	}
	
	func ExecuteDestructiveUndo(commandContext: DestructiveUndoData, context: any TextfieldContext) {
		let range = NSMakeRange(
			commandContext.startCursorPos,
			commandContext.deletedString.count
		)
		
		context.storage.deleteCharacters(in: range)
		context.cursorIndex = commandContext.startCursorPos - commandContext.deletedString.count
		
		self.commandContext = DestructiveUndoData(
			startCursorPos: context.cursorIndex,
			deletedString: commandContext.deletedString
		)
	}
	
}


//TODO: finish This
class Insert {
	
}

class NewLine: BaseConstructiveBehaviour, Command {

	func execute(_ context: any TextfieldContext) {
		_ = deleteSelection(context)
		
		let newLine = "\n"
		
		commandContext = DestructiveUndoData(
			startCursorPos: context.cursorIndex,
			deletedString: newLine
		)
		
		context.storage.insertOrAppend(at: context.cursorIndex, with: newLine)
		context.cursorIndex += 1
		
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	

}

class Paste: BaseConstructiveBehaviour, Command {
	
	func execute(_ context: any TextfieldContext) {
		guard let original = NSPasteboard.general.string(forType: .string)
		else { return }
		
		_ = deleteSelection(context)
		

		context.storage.insertOrAppend(at: context.cursorIndex, with: original)
		context.cursorIndex += original.count
		
		commandContext = DestructiveUndoData(
			startCursorPos: context.cursorIndex,
			deletedString: original
		)
		
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
}

class Copy: Command {
	func execute(_ context: any TextfieldContext) {
		guard let selectionRange = context.selectionRange else { return }
		
		let string = context.storage.string
		let range = string.makeRange(with: selectionRange)
		NSPasteboard.fill(with: String(string[range]))
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
}

class Cut: Command, Undoable {
	var commandContext: DestructiveUndoData? = nil
	
	func execute(_ context: any TextfieldContext) {
		guard let selectionRange = context.selectionRange else { return }
		
		let string = context.storage.string
		let range = string.makeRange(with: selectionRange)
		let affectedString = String(string[range])
		NSPasteboard.fill(with: affectedString)
		
		commandContext = DestructiveUndoData(
			startCursorPos: selectionRange.location,
			deletedString: affectedString
		)
		
		_ = deleteSelection(context)
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		guard let commandContext else { return }
		
		context.storage
			.insertOrAppend(
				at: commandContext.startCursorPos,
				with: commandContext.deletedString
			)
		
		context.cursorIndex = commandContext.startCursorPos +
		commandContext.deletedString.count
		
		context.selectionRange = NSMakeRange(
			commandContext.startCursorPos,
			commandContext.deletedString.count
		)
		
		self.commandContext = nil
		
	}
}
