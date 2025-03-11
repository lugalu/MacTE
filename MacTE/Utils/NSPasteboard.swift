//Created by Lugalu on 11/03/25.

import AppKit


func sendToPasteboard(_ string: String) {
	NSPasteboard.general.clearContents()
	NSPasteboard.general.setString(string, forType: .string)
}
