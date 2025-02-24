//Created by Lugalu on 24/02/25.

import AppKit

//MARK: Backspace Operations
class Backspace: Command {
	func execute(_ context: any TextfieldContext) {
		guard context.storage.length > 0 else { return }
		let deleteRange = NSRange(location: context.cursorIndex - 1, length: 1)
		context.storage.deleteCharacters(in: deleteRange)
		context.cursorIndex -= 1
	}
}

class WordBackspace: Command {
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
		storage.deleteCharacters(in: deletionRange)
	}
}


//MARK: Delete Operations
class Delete: Command {
	func execute(_ context: any TextfieldContext) {
		guard context.cursorIndex < context.storage.length else { return }
		let deleteRange = NSRange(location: context.cursorIndex, length: 1)
		context.storage.deleteCharacters(in: deleteRange)
	}
}


class WordDelete: Command {
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
}

class DeleteToBegginingOfLine: Command {
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
		storage.deleteCharacters(in: .init(location: distance, length: lenght))
	}
}


