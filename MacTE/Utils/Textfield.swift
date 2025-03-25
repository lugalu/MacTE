//Created by Lugalu on 24/02/25.

import AppKit

func isValid(range: NSRange) -> Bool {
	return range.location != NSNotFound && range.length > 0
}

func deleteSelection(_ context: any TextfieldContext) -> (Bool, String?) {
	guard let range = context.selectionRange,
		  isValid(range: range)
	else { return (false,nil) }
	
	let str = NSString(string:context.storage.string).substring(with: range)
	context.storage.deleteCharacters(in: range)
	context.cursorIndex = range.location
	context.selectionRange = nil
	
	return (true, str)
}


