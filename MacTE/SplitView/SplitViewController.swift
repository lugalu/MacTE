//Created by Lugalu on 03/02/25.

import AppKit

class SplitViewController: NSSplitViewController {
	lazy var itemA: NSSplitViewItem = NSSplitViewItem()
	lazy var itemB: NSSplitViewItem = NSSplitViewItem()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		self.splitView.dividerStyle = .paneSplitter
		
		let vcA = FileListingViewController()
		vcA.view.wantsLayer = true
		vcA.view.layer?.backgroundColor = NSColor.secondarySystemFill.cgColor
		
		let vcB = NSViewController()
		vcB.view.wantsLayer = true
		vcB.view.layer?.backgroundColor = .init(
			red: 0,
			green: 0,
			blue: 1,
			alpha: 1
		)
		
		itemA = NSSplitViewItem(sidebarWithViewController: vcA)
		itemA.minimumThickness = 200
		itemA.maximumThickness = 300
		itemA.allowsFullHeightLayout = true
		itemA.preferredThicknessFraction = 0.2
		
		itemB = NSSplitViewItem(contentListWithViewController: vcB)
		itemB.canCollapse = false
		itemB.holdingPriority = .defaultLow
		
		addSplitViewItem(itemA)
		addSplitViewItem(itemB)
	}
	
	@objc func toggleSidebar() {
		itemA.isCollapsed.toggle()
	}
	
}

class FileListingViewController: NSViewController {
	var outlineView = NSOutlineView()
	var treeController = NSTreeController()
	@objc dynamic private(set) var nodes: [FileSystemNode] = []
	
	private(set) var scrollView = NSScrollView()
	
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
		cell.configure(name: data.name)
		
		return cell
	}
}


