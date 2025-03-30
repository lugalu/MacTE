//Created by Lugalu on 25/03/25.

import AppKit

extension NSLayoutManager {
	func lineNumber(for target: Int) -> Int {
		var numberOfLines = 0
		var index = 0
		let range: NSRangePointer = .allocate(capacity: 1)
		
		while index < target {
			self.lineFragmentRect(forGlyphAt: index, effectiveRange:  range)
			index = NSMaxRange(range.pointee)
			numberOfLines += 1
		}
		
		return numberOfLines
	}
}
