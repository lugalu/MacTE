//Created by Lugalu on 02/03/25.

import AppKit

extension NSEvent.ModifierFlags {
	func getNames() -> [String] {
		let cleanFlagMask = self.intersection(.deviceIndependentFlagsMask)
		var result = [String]()
		
		for mask in getModifierArray() {
			let value = cleanFlagMask.rawValue & mask.rawValue
			let currentMask = NSEvent.ModifierFlags(rawValue: value)
			result.append(NSEvent.ModifierFlags.getName(for: currentMask))
		}
		
		return result.filter({ !$0.isEmpty })
	}
	
	static func getName(for mod: NSEvent.ModifierFlags) -> String {
		return switch mod {
			case .command:
				"command"
				
			case .capsLock:
				"capslock"
				
			case .control:
				"control"
				
			case .function:
				"function"
				
			case .help:
				"help"
				
			case .numericPad:
				"numericPad"
				
			case .option:
				"option"
				
			case .shift:
				"shift"
				
			default:
				""
		}
	}
	
	func getModifierArray() -> [NSEvent.ModifierFlags] {
		return [
			.command,
			.control,
			.capsLock,
			.function,
			.help,
			.numericPad,
			.option,
			.shift
		]
	}
	
}
