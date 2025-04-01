//Created by Lugalu on 01/04/25.

import AppKit

extension CustomTextfield {
	override func mouseDown(with event: NSEvent) {
		let idx = characterIndex(
			for: windowToPoint(with: event.locationInWindow))
		
		self.cursorIndex = idx
		selectionRange = nil
	}
	
	func windowToPoint(with event: NSPoint) -> NSPoint {
		var point = convert(event, from: nil)
		point.y = max(0, point.y - TextfieldConstants.padding)
		point.x = max(0, point.x - TextfieldConstants.padding)
		
		return point
	}
	
	override func mouseDragged(with event: NSEvent) {
		let idx = characterIndex(
			for: windowToPoint(with: event.locationInWindow))

		selectionRange = NSMakeRange(
			min(idx, cursorIndex),
			abs(idx - cursorIndex)
		)

		needsDisplay = true
	}
}
