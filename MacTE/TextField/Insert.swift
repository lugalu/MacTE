//Created by Lugalu on 24/02/25.

import AppKit

class NewLine: Command, Undoable {
	
	func execute(_ context: any TextfieldContext) {
		_ = deleteSelection(context)
		
		let newLine = NSAttributedString(string: "\n")
		context.storage.insertOrAppend(at: context.cursorIndex, with: newLine)
		context.cursorIndex += 1
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		
	}
	
	func redo(_ context: TextfieldContext) {
		
	}
}

class Paste: Command, Undoable {
	
	func execute(_ context: any TextfieldContext) {
		guard let original = NSPasteboard.general.string(forType: .string)
		else { return }
		
		_ = deleteSelection(context)
		
		let string = NSAttributedString(string: original)
		context.storage.insertOrAppend(at: context.cursorIndex, with: string)
		context.cursorIndex += string.length
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		
	}
	
	func redo(_ context: TextfieldContext) {
		
	}
}

class Copy: Command {
	func execute(_ context: any TextfieldContext) {
		guard let selectionRange = context.selectionRange else { return }
		
		let string = context.storage.string
		let range = makeStringRange(string, range: selectionRange)
		sendToPasteboard(String(string[range]))
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
}

class Cut: Command, Undoable {
	
	func execute(_ context: any TextfieldContext) {
		guard let selectionRange = context.selectionRange else { return }
		
		let string = context.storage.string
		let range = makeStringRange(string, range: selectionRange)
		sendToPasteboard(String(string[range]))
		
		_ = deleteSelection(context)
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		
	}
	
	func redo(_ context: TextfieldContext) {
		
	}
}
