//Created by Lugalu on 24/02/25.

import AppKit

protocol Command {
	func execute(_ context: TextfieldContext)
}


protocol TextfieldContext: AnyObject {
	var cursorIndex: Int { get set }
	var storage: NSTextStorage { get }
	var container: NSTextContainer { get }
	var layoutManager: NSLayoutManager { get }	
}
