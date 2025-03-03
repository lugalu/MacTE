//Created by Lugalu on 24/02/25.

import AppKit

//MARK: Backspace Operations
class Backspace: Command, Undoable {
	var commandContext: CommandContext? = nil

	func execute(_ context: any TextfieldContext) {
		guard context.storage.length > 0, context.cursorIndex > 0 else { return }
		let deleteRange = NSRange(location: context.cursorIndex - 1, length: 1)
		
		let str = context.storage.string
		let idx = str.index(str.startIndex, offsetBy: context.cursorIndex - 1)
		let char = str[idx]
		
		commandContext = makeCommandContext(context, String(char))
		CommandStack.shared.push(command: self)
		
		context.storage.deleteCharacters(in: deleteRange)
		context.cursorIndex -= 1
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo() {
		
	}
}

class WordBackspace: Command, Undoable {
	var commandContext: CommandContext? = nil
	
	func execute(_ context: any TextfieldContext) {
		let storage = context.storage
		let cursorIndex = context.cursorIndex
		
		guard storage.length > 0, cursorIndex <= storage.length else { return }
		let string = storage.string
		let upperBound = string.index(string.startIndex,
									  offsetBy: cursorIndex - 1)
		let range = string.startIndex...upperBound
		
		guard let word = string[range]
			.components(separatedBy: .whitespacesAndNewlines)
			.last,
			  !word.isEmpty
		else { return }
		
		
		
		let difference = cursorIndex - word.count
		let deletionRange = NSRange(difference...cursorIndex-1)
		
		context.cursorIndex = difference
		
		commandContext = makeCommandContext(context, word)
		CommandStack.shared.push(command: self)
		
		storage.deleteCharacters(in: deletionRange)
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo() {
		
	}
}


//MARK: Delete Operations
class Delete: BaseCommand, Undoable {
	var commandContext: CommandContext? = nil
	
	override func execute(_ context: any TextfieldContext) {
		guard context.cursorIndex < context.storage.length else { return }
		let deleteRange = NSRange(location: context.cursorIndex, length: 1)
		
		
		let str = context.storage.string
		let idx = str.index(str.startIndex, offsetBy: context.cursorIndex)
		let char = str[idx]
		
		super.execute(context)
		commandContext = makeCommandContext(context, String(char))
		CommandStack.shared.push(command: self)
		context.cursorIndex = context.cursorIndex
		context.storage.deleteCharacters(in: deleteRange)
	}
	
	override func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo() {
		
	}
}


class WordDelete: Command, Undoable {
	var commandContext: CommandContext? = nil
	
	func execute(_ context: any TextfieldContext) {
		let storage = context.storage
		let cursorIndex = context.cursorIndex
		
		guard storage.length > 0, cursorIndex < storage.length else { return }
		let string = storage.string
		let lowerBound = string.index(string.startIndex, offsetBy: cursorIndex)
		let stringRange = lowerBound...
		
		guard let word = string[stringRange]
			.components(separatedBy: .whitespacesAndNewlines)
			.first,
			  !word.isEmpty
		else {
			return
		}
		
		commandContext = makeCommandContext(context, word)
		CommandStack.shared.push(command: self)
		
		let difference = cursorIndex + word.count-1
		let deletionRange = NSRange(cursorIndex...difference)
		
		storage.deleteCharacters(in: deletionRange)
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo() {
		
	}
}

class DeleteToBegginingOfLine: Command, Undoable {
	var commandContext: CommandContext? = nil
	
	func execute(_ context: any TextfieldContext) {
		let storage = context.storage
		let cursorIndex = context.cursorIndex
		guard cursorIndex <= storage.length else { return }
		let string = storage.string
		
		let upperBound = string.index(string.startIndex,
									  offsetBy: cursorIndex - 1)
		let range = string.startIndex...upperBound
		
		let idx = string[range].lastIndex(where: { $0 == "\n" }) ?? string.index(
			string.startIndex,
			offsetBy: 0
		)

		var distance: Int
		
		if idx == string.startIndex {
			distance = 0
		}else {
			distance = string.distance(
			   from: string.startIndex,
			   to: string.index(after: idx)
		   )
		}	
		
		let lenght = cursorIndex - distance
		
		context.cursorIndex = max(abs(cursorIndex - lenght), 0)
		
		let phrase = String(string[idx...upperBound])
		commandContext = makeCommandContext(context, phrase)
		CommandStack.shared.push(command: self)
		
		storage.deleteCharacters(in: .init(location: distance, length: lenght))
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo() {
		
	}
}


