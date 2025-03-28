//Created by Lugalu on 24/02/25.

import AppKit

class BaseConstructiveBehaviour: Undoable {
	var commandContext: UndoData? = nil
	
	func undo(_ context: TextfieldContext) {
		guard let commandContext else { return }
		context.selectionRange = nil
		ExecuteDestructiveUndo(commandContext: commandContext, context: context)
		
		self.commandContext = UndoData(
			startCursorPos: context.cursorIndex,
			deletedString: commandContext.deletedString
		)
	}
	
	func ExecuteDestructiveUndo(commandContext: UndoData, context: any TextfieldContext) {
		let range = NSMakeRange(
			commandContext.startCursorPos,
			commandContext.deletedString.count
		)
		
		context.storage.deleteCharacters(in: range)
		context.cursorIndex = commandContext.startCursorPos - commandContext.deletedString.count
		
		self.commandContext = UndoData(
			startCursorPos: context.cursorIndex,
			deletedString: commandContext.deletedString
		)
	}
	
}

class Insert: Command, Undoable  {
	var commandContext: UndoData? = nil
	var replacedContext: UndoData? = nil
	
	func execute(_ context: any TextfieldContext) {
		fatalError("Error Insert must have a string")
	}
		
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		guard let stringToInsert = inserting else { return }

		if let selectionRange = context.selectionRange,
		   isValid(range: selectionRange) {
			let stringToReplace =  context.storage
				.attributedSubstring(from: selectionRange)

			context.storage
				.deleteCharacters(in: selectionRange)

			context.cursorIndex = selectionRange.location
			replacedContext = UndoData(
				startCursorPos: context.cursorIndex,
				deletedString: stringToReplace.string
			)
			context.selectionRange = nil
		}
		
		commandContext = UndoData(
			startCursorPos: context.cursorIndex,
			deletedString: stringToInsert
		)
		
		
		context.storage.insertOrAppend(at: context.cursorIndex,
									   with: stringToInsert)
		
		context.cursorIndex += stringToInsert.count
	}
	
	func undo(_ context: any TextfieldContext) {
		guard let commandContext else { return }
		
		let range = NSMakeRange(
			commandContext.startCursorPos,
			commandContext.deletedString.count
		)
		
		context.storage.deleteCharacters(in: range)
		context.cursorIndex -= commandContext.deletedString.count
		if let replacedContext {
			context.storage
				.insertOrAppend(
					at: replacedContext.startCursorPos,
					with: replacedContext.deletedString
				)
			let newSelectionRange = NSMakeRange(
				replacedContext.startCursorPos,
				replacedContext.deletedString.count
			)
			context.selectionRange = newSelectionRange
			
			self.replacedContext = nil
		}
		
		self.commandContext = UndoData(
			startCursorPos: context.cursorIndex,
			deletedString: commandContext.deletedString
		)
		
	}
}

class NewLine: BaseConstructiveBehaviour, Command {

	func execute(_ context: any TextfieldContext) {
		_ = deleteSelection(context)
		
		let newLine = "\n"
		
		commandContext = UndoData(
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
		
		commandContext = UndoData(
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
	var commandContext: UndoData? = nil
	
	func execute(_ context: any TextfieldContext) {
		guard let selectionRange = context.selectionRange else { return }
		
		let string = context.storage.string
		let range = string.makeRange(with: selectionRange)
		let affectedString = String(string[range])
		NSPasteboard.fill(with: affectedString)
		
		commandContext = UndoData(
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
