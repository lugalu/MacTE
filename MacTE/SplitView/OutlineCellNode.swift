//Created by Lugalu on 14/02/25.

import AppKit

class OutlineCellNode: NSTableCellView {
	var label: NSTextField = {
		let txt = NSTextField()
		txt.translatesAutoresizingMaskIntoConstraints = false
		txt.isBezeled = false
		txt.isBordered = false
		txt.isEditable = false
		txt.isSelectable = false
		
		return txt
	}()
	
	func configure(name: String) {
		if label.superview == nil {
			self.addSubview(label)
			
			let constraints = [
				label.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
				label.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 8),
				label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
				label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
			]
			NSLayoutConstraint.activate(constraints)
		}
		label.stringValue = name
	}
}
