//Created by Lugalu on 24/02/25.

import AppKit

func lineNumber(for target: Int, context: TextfieldContext) -> Int {
	var numberOfLines = 0
	var index = 0
	let range: NSRangePointer = .allocate(capacity: 4)
	
	while index < target {
		context.layoutManager.lineFragmentRect(forGlyphAt: index,
											   effectiveRange:  range)
		index = NSMaxRange(range.pointee)
		numberOfLines += 1
	}
	
	return numberOfLines
}
