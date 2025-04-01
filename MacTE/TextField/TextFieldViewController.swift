//Created by Lugalu on 31/03/25.

import AppKit

protocol TextFieldCommunication {
	func saveIfNeeded()
}

class TextFieldViewController: NSViewController, TextFieldCommunication {
	var openFileURL: URL? = nil
	var currentFileContents: String? = nil
	var textView: CustomTextfield? {
		return self.view as? CustomTextfield
	}
	
	override func viewDidLoad() {
		let newView = CustomTextfield()
		newView.delegate = self
		self.view = newView
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
		
		
		saveIfNeeded() {
			textView.setNewText(newText)
			self.currentFileContents = newText
			self.openFileURL = fileURL
			CommandStack.shared.clear()
		}
		
		
	}
	
	func saveIfNeeded() {
		saveIfNeeded(nil)
	}

	
	func saveIfNeeded(_ completion: (() -> Void)? = nil) {
		guard let textView else { return }
		
		if
			let currentFileContents,
			let openFileURL,
			currentFileContents.hashValue != textView.textHash {
			let result = saveTextViewText(to: openFileURL)
			guard result else { return }
			
			completion?()
			
			return
		}
		
		if currentFileContents == nil, !textView.isEmpty {
			saveAsNewFile(completion)
			return
		}
		
		completion?()
		
	}
	
	func saveAsNewFile(_ completion: (() -> Void)? = nil) {
		let savePanel = NSSavePanel()
		savePanel.canCreateDirectories = true
		savePanel.begin {[weak self] response in
			guard
				response == .OK,
				let url = savePanel.url,
				let self
			else { return }
			
			let result = self.saveTextViewText(to: url)
			guard result, let completion  else {
				guard let textView else { return }
				self.currentFileContents = textView.text
				self.openFileURL = url
				return
			}
			completion()
		}
	}
	
	func saveTextViewText(to url: URL) -> Bool {
		guard let textView,
			  let data = textView.text.data(using: .utf8)
		else { return false }
		
		do {
			try data.write(to: url)
			return true
		}catch {
			showErrorAlert()
			return false
		}
	}
	
	func showErrorAlert() {
		print("failed to write the file")
	}
}
