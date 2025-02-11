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

class TestNodeFactory {
	static func getNodes() -> [FileSystemNode] {
		var arr: [FileSystemNode] = []
		
		arr.append(FileSystemNode(name: "Haha", type: .file(fileExtension: "txt")))
		let folder = FileSystemNode(name: "testr", type: .folder)
		folder.children = [
			.init(name: "test2", type: .file(fileExtension: "json")),
			.init(name: "test3", type: .file(fileExtension: "hm"))
		]
		
		arr.append(folder)
		
		return arr
	}
}

class FileListingViewController: NSViewController {
	var outlineView = NSOutlineView()
	var treeController = NSTreeController()
	@objc dynamic private(set) var nodes: [FileSystemNode] = TestNodeFactory.getNodes()
	
	private(set) var scrollView = NSScrollView()
	
	override func viewDidLoad() {
		self.view = scrollView
		
		scrollView.contentView.addSubview(outlineView)

		outlineView.delegate = self

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
		var cell = OutlineCellNode()
		cell.configure(name: data.name)
		
		return cell
	}
}

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
