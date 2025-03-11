//Created by Lugalu on 24/02/25.

import AppKit

protocol Command {
	func execute(_ context: TextfieldContext)
	func execute(_ context: TextfieldContext, _ inserting: String?)
}

protocol Undoable {
	var commandContext: CommandContext? { get }
	func undo()
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
	var cursor: NSTextInsertionIndicator { get }
	var storage: NSTextStorage { get }
	var container: NSTextContainer { get }
	var layoutManager: NSLayoutManager { get }
	var selectionRange: NSRange? { get set }
	var selectionPath: NSBezierPath? { get }


}

class CommandStack {
	typealias Undo = (Undoable & Command)
	static let shared = CommandStack()
	
	var undoStack: [Undo] = []
	var redoStack: [Undo] = []
	
	private init(){}
	
	func push(command: Command, with context: TextfieldContext) {
		command.execute(context)
		
		if command is Undoable {
			undoStack.append(command as! Undo)
		}
	}
	
	func undo(){
		guard !undoStack.isEmpty else { return }
		let command = undoStack.removeFirst()
		command.undo()
	}
	
	func redo(){
		guard !redoStack.isEmpty else { return }
		let command = redoStack.removeFirst()
		guard let context = command.commandContext else { return }
		command.execute(context.originalContext, context.modification)
	}
	
}
func setMarkedText(
	_ string: Any,
	selectedRange: NSRange,
	replacementRange: NSRange
) {}


func unmarkText() {}

func selectedRange() -> NSRange {
	return .init()
}

func markedRange() -> NSRange {
	return .init()
}

func hasMarkedText() -> Bool {
	return false
}

func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
	return nil
}

func validAttributesForMarkedText() -> [NSAttributedString.Key] {
	return []
}

