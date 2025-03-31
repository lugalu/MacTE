//Created by Lugalu on 31/03/25.

import AppKit

class FileListingViewController: NSViewController {
	var outlineView = NSOutlineView()
	var treeController = NSTreeController()
	var delegate: SplitViewDelegate? = nil
	
	@objc dynamic private(set) var nodes: [FileSystemNode] = []
	
	private(set) var scrollView = NSScrollView()
	
	init(delegate: SplitViewDelegate?) {
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		self.view = scrollView
		self.scrollView.documentView = outlineView
		addOutlineView()
		selectFiles()
	}
	
	func selectFiles() {
		let systemPanel = NSOpenPanel()
		systemPanel.canChooseFiles = true
		systemPanel.canChooseDirectories = true
		systemPanel.allowsMultipleSelection = true
		systemPanel.allowedContentTypes = [.text, .sourceCode, .folder]
		
		systemPanel.begin { [weak self] response in
			guard response == .OK, let self else { return }
			self.nodes = onFileSelection(withPanel: systemPanel)
		}
	}
	
	func onFileSelection(withPanel systemPanel: NSOpenPanel) -> [FileSystemNode] {
		var newNodes: [FileSystemNode] = []
		
		for url in systemPanel.urls {
			guard let isDirectory = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory else {
				continue
			}

			let name = (url.absoluteString as NSString).lastPathComponent
			var node: FileSystemNode
			
			if isDirectory {
				node = FileSystemNode.createFolder(withName: name, url: url)
				
			}else {
				guard let newNode = FileSystemNode.createFile(
					withName: name,
					url: url
				) else { continue }
				
				node = newNode
				
			}
			
			newNodes.append(node)
		}
		
		return newNodes
	}
	
	
	func addOutlineView() {
		outlineView.delegate = self
		outlineView.headerView = nil
		
		outlineView.action = #selector(onOutlineClick(_:))
		
		let nodeColumn = NSTableColumn(identifier: .init("node"))
		outlineView.addTableColumn(nodeColumn)
		
		treeController.objectClass = FileSystemNode.self
		treeController.childrenKeyPath = "children"
		treeController.leafKeyPath = "isLeaf"
		treeController.countKeyPath = "childrenCount"
		
		outlineView.gridStyleMask = .solidHorizontalGridLineMask
		outlineView.autosaveExpandedItems = true
		
		treeController.bind(NSBindingName("contentArray"),
							to: self,
							withKeyPath: "nodes"
		)
		
		outlineView.bind(NSBindingName("content"),
						 to: treeController,
						 withKeyPath: "arrangedObjects"
		)
	}
	
	func add(node: FileSystemNode ) {
		self.nodes.append(node)
	}
}

extension FileListingViewController: NSOutlineViewDelegate {
	
	func outlineView(_ outlineView: NSOutlineView,
					 viewFor tableColumn: NSTableColumn?,
					 item: Any) -> NSView? {
		guard let item = item as? NSTreeNode, let data = item.representedObject as? FileSystemNode else {
			return nil
		}
		
		let cell = OutlineCellNode()
		cell.configure(node: data)
		
		return cell
	}
	
	@objc func onOutlineClick(_ sender: NSOutlineView){
		
		let row = sender.clickedRow
		guard
			row != -1,
			let treeNode = sender.item(atRow: row) as? NSTreeNode,
			let cell = treeNode.representedObject as? FileSystemNode,
			case FileSystemType.file = cell.type
		else { return }
				
		delegate?.didSelectFile(cell.url)
	}
	
}
