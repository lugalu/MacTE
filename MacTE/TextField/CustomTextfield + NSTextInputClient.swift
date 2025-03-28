//Created by Lugalu on 28/03/25.

import AppKit


extension CustomTextfield: NSTextInputClient {
	
	func insertText(_ string: Any, replacementRange: NSRange) {
		guard let string = string as? String,
			  let command = TextfieldConstants.commands[TextfieldConstants.insert]
		else {
			return
		}
		
		CommandStack.shared.push(
			command: command(self),
			with: self,
			string: string)
	}
	

	
	func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
		return layoutManager
			.lineFragmentRect(
				forGlyphAt: range.lowerBound,
				effectiveRange: actualRange
			)
	}
	
	func characterIndex(for point: NSPoint) -> Int {
		
		let pointer: UnsafeMutablePointer<CGFloat> = .allocate(capacity: 1)
		pointer.pointee = 1
		defer{
			pointer.deallocate()
		}
		
		var idx = layoutManager
			.characterIndex(
				for: point,
				in: container,
				fractionOfDistanceBetweenInsertionPoints: pointer
			)
		
		idx += pointer.pointee >= 0.5 ? 1 : 0
		
		return idx
	}
	
	override func doCommand(by selector: Selector) {
		let commandKey = selector.description
		guard let command = TextfieldConstants.commands[commandKey] else {
			return
		}
		
		pushCommandToStack(command: command(self))
	}
	
	func pushCommandToStack(command: Command) {
		CommandStack.shared.push(command: command, with: self)
	}
	
	
	//Unused
	func setMarkedText(
		_ string: Any,
		selectedRange: NSRange,
		replacementRange: NSRange
	) {}

	
	func unmarkText() {}
	
	func selectedRange() -> NSRange {
		return .init()
	}
	
	func markedRange() -> NSRange {
		return .init()
	}
	
	func hasMarkedText() -> Bool {
		return false
	}
	
	func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
		return nil
	}
	
	func validAttributesForMarkedText() -> [NSAttributedString.Key] {
		return []
	}
}

