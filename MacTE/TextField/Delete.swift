//Created by Lugalu on 24/02/25.

import AppKit


func test(commandContext: DestructiveUndoData, context: any TextfieldContext) {
	context.storage.insertOrAppend(
		at: commandContext.startCursorPos,
		with: commandContext.deletedString
	)
	context.cursorIndex = commandContext.startCursorPos + commandContext.deletedString.count
}

//MARK: Backspace Operations
class Backspace: Command, Undoable {
	private var commandContext: DestructiveUndoData? = nil

	func execute(_ context: any TextfieldContext) {
		let (didDelete, deletedString) = deleteSelection(context)
		guard !didDelete else {
			if let deletedString {
				commandContext = DestructiveUndoData(
					startCursorPos: context.cursorIndex,
					deletedString: deletedString
				)
			}
			return
		}
		
		guard context.storage.length > 0, context.cursorIndex > 0 else { return }
		let deleteRange = NSRange(location: context.cursorIndex - 1, length: 1)
		
		let str = context.storage.string
		let idx = str.index(str.startIndex, offsetBy: context.cursorIndex - 1)
		let char = String(str[idx])
				
		context.storage.deleteCharacters(in: deleteRange)
		context.cursorIndex -= 1
		commandContext = DestructiveUndoData(
			startCursorPos: context.cursorIndex,
			deletedString: char
		)
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		guard let commandContext else { return }
		test(commandContext: commandContext, context: context)
	}
	
	func redo(_ context: TextfieldContext){
		
	}
}

class WordBackspace: Command, Undoable {
	private var commandContext: DestructiveUndoData? = nil
	
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
		
		let targetStr = NSString(string: context.storage.string)
			.substring(with: deletionRange)
		
		commandContext = DestructiveUndoData(
			startCursorPos: difference,
			deletedString: targetStr
		)
		
		context.cursorIndex = difference
		
		storage.deleteCharacters(in: deletionRange)
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		guard let commandContext else { return }
		test(commandContext: commandContext, context: context)
	}
	
	func redo(_ context: TextfieldContext) {
		
	}
}


//MARK: Delete Operations
class Delete: Command, Undoable {
	
	func execute(_ context: any TextfieldContext) {
		let (didDelete, deletedString) = deleteSelection(context)
		guard !didDelete else {
			return
		}
		
		guard context.cursorIndex < context.storage.length else { return }
		let deleteRange = NSRange(location: context.cursorIndex, length: 1)
		
		
		let str = context.storage.string
		let idx = str.index(str.startIndex, offsetBy: context.cursorIndex)
		let char = str[idx]
		
		context.cursorIndex = context.cursorIndex
		context.storage.deleteCharacters(in: deleteRange)
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		
	}
	
	func redo(_ context: TextfieldContext) {
		
	}
}


class WordDelete: Command, Undoable {
	
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
		
		let difference = cursorIndex + word.count-1
		let deletionRange = NSRange(cursorIndex...difference)
		
		storage.deleteCharacters(in: deletionRange)
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		
	}
	
	func redo(_ context: TextfieldContext) {
		
	}
}

class DeleteToBegginingOfLine: Command, Undoable {
	
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
		
		storage.deleteCharacters(in: .init(location: distance, length: lenght))
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo(_ context: TextfieldContext) {
		
	}
	
	func redo(_ context: TextfieldContext) {
		
	}
}


