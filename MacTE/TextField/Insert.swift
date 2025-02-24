//Created by Lugalu on 24/02/25.

import AppKit

class NewLine: Command {
	func execute(_ context: any TextfieldContext) {
		let newLine = NSAttributedString(string: "\n")
		
		if context.cursorIndex <= context.storage.length {
			context.storage.insert(newLine, at: context.cursorIndex)
		}else {
			context.storage.append(newLine)
		}
		
		context.cursorIndex += 1
	}
}
