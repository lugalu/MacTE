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

	var url: URL
	
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

	
	init(name: String,type: FileSystemType, url: URL) {
		self.baseName = name
		self.type = type
		self.url = url
	}
	
	static func createFolder(withName name: String, url: URL) -> FileSystemNode {
		let node = FileSystemNode(name: name, type: .folder, url: url)
		if let childrenNodes = node.getChilden() {
			node.children.append(contentsOf: childrenNodes)
		}
		return node
	}
	
	static func createFile(withName name: String, url: URL) -> FileSystemNode? {
		let components = name.components(separatedBy: ".")
		guard let name = components.first, let fileExtension = components.last else {
			return nil
		}
		
		let node = FileSystemNode(
			name: name,
			type: .file(fileExtension: fileExtension),
			url: url
		)

		return node
	}
	
	func getChilden() -> [FileSystemNode]? {
		if case .file = self.type { return nil }
		
		guard let enumerator = FileManager.default.enumerator(
			at: self.url,
			includingPropertiesForKeys: [.isRegularFileKey],
			options: [
				.skipsHiddenFiles,
				.skipsPackageDescendants,
				.skipsSubdirectoryDescendants
			]
		) else {
			return nil
		}
		
		var childrens: [FileSystemNode] = []
		
		autoreleasepool{
			for case let fileURL as URL in enumerator {
				guard let fileAttributes = try? fileURL.resourceValues(
					forKeys:[.isDirectoryKey, .nameKey]),
					  let isDirectory = fileAttributes.isDirectory,
					  let name = fileAttributes.name
				else { continue }
				
				var childNode: FileSystemNode
				if isDirectory {
					childNode = FileSystemNode
						.createFolder(withName: name, url: fileURL)
				}else {
					guard let newNode = FileSystemNode.createFile(
						withName: name,
						url: fileURL
					) else {
						continue
					}
					
					childNode = newNode
				}
				
				childrens.append(childNode)
			}
		}
		
		return childrens
		
	}
	
}
