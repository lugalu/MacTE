//Created by Lugalu on 24/02/25.

import AppKit

class NewLine: Command, Undoable {
	var commandContext: CommandContext? = nil
	
	func execute(_ context: any TextfieldContext) {
		let newLine = NSAttributedString(string: "\n")
		
		if context.cursorIndex <= context.storage.length {
			context.storage.insert(newLine, at: context.cursorIndex)
		}else {
			context.storage.append(newLine)
		}
		
		commandContext = makeCommandContext(context, "\n")
		CommandStack.shared.push(command: self)
		
		context.cursorIndex += 1
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
	
	func undo(_ context: CommandContext) {
		
	}
}
