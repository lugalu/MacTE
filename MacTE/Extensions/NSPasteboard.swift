//Created by Lugalu on 25/03/25.

import AppKit

extension NSPasteboard {
	static func fill(with string: String) {
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString(string, forType: .string)
	}
}
