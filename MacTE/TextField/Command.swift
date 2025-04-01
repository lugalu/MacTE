//Created by Lugalu on 24/02/25.

import AppKit

protocol Command {
	func execute(_ context: TextfieldContext)
	func execute(_ context: TextfieldContext, _ inserting: String?)
}

protocol Undoable {
	func undo(_ context: TextfieldContext)
}

protocol TextfieldContext: AnyObject {
	var cursorIndex: Int { get set }
	var cursor: NSTextInsertionIndicator { get }
	var storage: NSTextStorage { get }
	var container: NSTextContainer { get }
	var layoutManager: NSLayoutManager { get }
	var selectionRange: NSRange? { get set }
	var selectionPath: NSBezierPath? { get }
	
	func save()
}



class NoOperation: Command {
	static let shared = NoOperation()
	
	private init() {}
	
	func execute(_ context: any TextfieldContext) {
		return
	}
	
	func execute(_ context: any TextfieldContext, _ inserting: String?) {
		return
	}
}
