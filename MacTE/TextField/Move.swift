//Created by Lugalu on 24/02/25.

import AppKit

class MoveLeft: Command {
	func execute(_ context: any TextfieldContext) {
		guard context.cursorIndex > 0 else { return }
		context.cursorIndex -= 1
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}

}

class MoveRight: Command {
	func execute(_ context: any TextfieldContext) {
		guard context.cursorIndex < context.storage.length else { return }
		context.cursorIndex += 1
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
}

class MoveUp: Command {
	func execute(_ context: any TextfieldContext) {
		let cursorIndex = context.cursorIndex
		let storage = context.storage
		let layoutManager = context.layoutManager
		
		guard cursorIndex > 0, cursorIndex <= storage.length else { return }
		
		let numberOfGlyphs = layoutManager.numberOfGlyphs
		let cursorLine = lineNumber(for: cursorIndex, context: context)
		
		guard cursorLine > 1 ||
				lineNumber(for: cursorIndex + 1, context: context) > 1 else {
			return
		}
		
		var previousLine:NSRange? = nil
		layoutManager.enumerateLineFragments(
			forGlyphRange: NSRange(0...numberOfGlyphs)
		) { (_,_,_, range, stop) in
			
			defer {
				previousLine = range
			}
			
			// for some reason contains wasn't checking it's upperBound so the edgeCase is checked on the if
			if (range.lowerBound...range.upperBound).contains(cursorIndex) {
				
				guard let previousLine else {
					return
				}
				
				let difference = cursorIndex - range.lowerBound
				let newCursor = previousLine.lowerBound + difference
				let lastLineEnd = previousLine.upperBound - 1
				
				context.cursorIndex = clamp(previousLine.lowerBound,
											newCursor,
											lastLineEnd
				)
				
				stop.pointee = true
				return
			}
		}
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
}

class MoveDown: Command {
	func execute(_ context: any TextfieldContext) {
		let layoutManager = context.layoutManager
		let storage = context.storage
		let cursorIndex = context.cursorIndex
		
		guard storage.length > 0 else { return }
		
		let numberOfGlyphs = layoutManager.numberOfGlyphs
		let lineCount = lineNumber(for: numberOfGlyphs, context: context)
		let cursorLine = lineNumber(for: cursorIndex, context: context)
		
		guard cursorLine < lineCount else { return }
		
		var cursorRange: NSRange? = nil
		layoutManager
			.enumerateLineFragments(
				forGlyphRange: NSRange(0...numberOfGlyphs)
			) { (_,_,_, range, stop) in
				
				if let validRange = cursorRange {
					let difference = cursorIndex - validRange.lowerBound
					let newCursor = range.lowerBound + difference
					context.cursorIndex = clamp(
						range.lowerBound,
						newCursor,
						range.upperBound
					)
					cursorRange = nil
					stop.pointee = true
					return
				}
				
				if range.contains(cursorIndex) {
					cursorRange = range
				}
				
			}
	}
	
	func execute(_ context: any TextfieldContext, _ : String?) {
		execute(context)
	}
}


