//Created by Lugalu on 24/02/25.

import AppKit

class NewLine: Command, Undoable {
	var commandContext: CommandContext? = nil
	
	func execute(_ context: any TextfieldContext) {
		let newLine = NSAttributedString(string: "\n")
		
		context.storage.insertOrAppend(at: context.cursorIndex, with: newLine)
		
		commandContext = makeCommandContext(context, "\n")
		
		context.cursorIndex += 1
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo() {
		guard let commandContext else { return }
		Backspace().execute(commandContext.originalContext)
	}
}

class Paste: Command, Undoable {
	var commandContext: CommandContext? = nil
	
	func execute(_ context: any TextfieldContext) {
		guard let original = NSPasteboard.general.string(forType: .string)
		else {
			return
		}
		
		let string = NSAttributedString(string: original)
		
		context.storage.insertOrAppend(at: context.cursorIndex, with: string)
		
		context.cursorIndex += string.length
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
	
	func undo() {
		
	}
}

class Copy: Command {
	func execute(_ context: any TextfieldContext) {
		guard let selectionRange = context.selectionRange else { return }
		
		let string = context.storage.string
		let lowerBound = string.index( string.startIndex,
			offsetBy: selectionRange.lowerBound
		)
		
		let upperBound = string.index( lowerBound,
			offsetBy: selectionRange.length
		)
		
		let newStr = String(string[lowerBound..<upperBound])
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString(newStr, forType: .string)		
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
}
