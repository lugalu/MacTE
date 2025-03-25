//Created by Lugalu on 25/03/25.

import Foundation


extension String {
	func makeRange(with range: NSRange) -> Range<String.Index> {
		let lowerBound = index(startIndex, offsetBy: range.lowerBound)
		let upperBound = index(lowerBound, offsetBy: range.length)
		
		return lowerBound..<upperBound
	}
}
