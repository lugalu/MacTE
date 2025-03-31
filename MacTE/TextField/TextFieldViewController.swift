//Created by Lugalu on 31/03/25.

import AppKit

class TextFieldViewController: NSViewController {
	var openFileURL: URL? = nil
	var currentFileContents: String? = nil
	var textView: CustomTextfield? {
		return self.view as? CustomTextfield
	}
	
	
	override func viewDidLoad() {
		self.view = CustomTextfield()
	}
	
	func loadFile(with fileURL: URL) {
		//TODO: asks the user to save the current file if needed,then we change the file!
		//TODO: it also should ask if the contents written that has no file, should be saved somewhere
		guard
			fileURL != openFileURL,
			let textView,
			let newData = FileManager.default.contents(
				atPath: fileURL.relativePath
			),
			let newText = String(data: newData, encoding: .utf8)
		else { return }
		
		if let currentFileContents,
		   currentFileContents.hashValue != textView.getTextHash() {
			print("has to save")
		}
		
		textView.setNewText(newText)
		currentFileContents = newText
		openFileURL = fileURL
		CommandStack.shared.clear()
	}
	
	func saveIfNeeded() {
		
	}
}
