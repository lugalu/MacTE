//Created by Lugalu on 11/03/25.

import AppKit

extension NSTextStorage {
	
	func insertOrAppend(at cursor: Int, with str: String) {
		insertOrAppend(at: cursor, with: .init(string: str))
	}
	
	func insertOrAppend(at cursor: Int, with str: NSAttributedString) {
		if cursor < self.length {
			self.insert(str, at: cursor)
		} else {
			self.append(str)
		}
	}
}
