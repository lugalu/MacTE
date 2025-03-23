//Created by Lugalu on 24/02/25.

import AppKit

func lineNumber(for target: Int, context: TextfieldContext) -> Int {
	var numberOfLines = 0
	var index = 0
	let range: NSRangePointer = .allocate(capacity: 1)
	
	while index < target {
		context.layoutManager.lineFragmentRect(forGlyphAt: index,
											   effectiveRange:  range)
		index = NSMaxRange(range.pointee)
		numberOfLines += 1
	}
	
	return numberOfLines
}

func makeStringPermutations(with array: [String]) -> [String] {
	var result: Set<String> = []
	
	
	array.enumerated().forEach { idx, value in
		result.insert(value)
		result.insert(array[idx...].reduce("", +))
	}

	
	return Array(result)
}

func makeStringRange(_ string: String, range: NSRange) -> Range<String.Index> {
	let lowerBound = string.index(string.startIndex, offsetBy: range.lowerBound)
	let upperBound = string.index(lowerBound, offsetBy: range.length)
	
	return lowerBound..<upperBound
}

func isValid(range: NSRange) -> Bool {
	return range.location != NSNotFound && range.length > 0
}

func deleteSelection(_ context: any TextfieldContext) -> Bool {
	guard let range = context.selectionRange,
		  isValid(range: range)
	else { return false }
	
	context.storage.deleteCharacters(in: range)
	context.cursorIndex = range.location
	context.selectionRange = nil
	
	return true
}
