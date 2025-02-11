//Created by Lugalu on 11/02/25.

import Foundation

enum FileSystemType {
	case folder
	case file(fileExtension: String)
}

class FileSystemNode: NSObject {
	
	private var baseName: String
	var type: FileSystemType
	@objc var children: [FileSystemNode] = []
	
	@objc var childrenCount: Int { children.count }
	
	@objc var isLeaf: Bool { children.isEmpty }

	
	@objc var name: String {
		var name = baseName
		
		switch type {
			case .folder:
				break
			case .file(let fileExtension):
				name += "." + fileExtension
		}
		
		return name
	}

	
	init(name: String,type: FileSystemType) {
		self.baseName = name
		self.type = type
	}
}
