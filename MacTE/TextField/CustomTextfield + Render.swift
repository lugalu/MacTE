//Created by Lugalu on 01/04/25.

import AppKit

extension CustomTextfield {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		NSColor.textBackgroundColor.setFill()
		dirtyRect.fill()
		
		storage.foregroundColor = NSColor.textColor
		
		let padding = TextfieldConstants.padding
		container.size = bounds.insetBy(dx: padding, dy: padding).size
		
		let glyphs = layoutManager.glyphRange(forBoundingRect: bounds,
											  in: container)
		
		let paddingPoint = CGPoint(x: padding, y: padding)
		layoutManager.drawBackground(forGlyphRange: glyphs, at: paddingPoint)
		layoutManager.drawGlyphs(forGlyphRange: glyphs, at: paddingPoint)
		
		cursor.setFrameOrigin(getCursorRect().origin)
		cursor.setFrameSize(.init(width: 100, height: cursor.frame.height))
		
		drawSelectionBox()
	}
	
	func drawSelectionBox() {
		guard let selectionRange, selectionRange.length != 0 else {
			NSColor.clear.setFill()
			selectionPath?.fill()
			selectionPath = nil
			return
		}
		
		var rect = layoutManager
			.boundingRect(forGlyphRange: selectionRange, in: container)
		rect.origin = rect
			.origin
			.applying(
				.init(translationX: TextfieldConstants.padding,
					  y: TextfieldConstants.padding))
		
		NSColor.selectedTextBackgroundColor
			.withAlphaComponent(0.3)
			.setFill()
		selectionPath = NSBezierPath(rect: rect)
		selectionPath?.fill()
	
	}
}
