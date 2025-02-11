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
	
	
	override func viewDidLoad() {
		let scroll = NSScrollView()
		self.view = scroll
		
		scroll.contentView.addSubview(outlineView)
		makeUI()

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
	
	func makeUI() {
//		view.addSubview(outlineView)
//		outlineView.frame = view.frame
	}
	
	
	func add(node: FileSystemNode ) {
		self.nodes.append(node)
	}
}

class ProgrammaticTableCellView: NSTableCellView {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)

		self.autoresizingMask = .width
		let iv: NSImageView = NSImageView(frame: NSMakeRect(0, 6, 16, 16))
		let tf: NSTextField = NSTextField(frame: NSMakeRect(21, 6, 200, 14))
		let btn: NSButton = NSButton(frame: NSMakeRect(0, 3, 16, 16))
		iv.imageScaling = .scaleProportionallyUpOrDown
		iv.imageAlignment = .alignCenter
		tf.isBordered = false
		tf.drawsBackground = false
		btn.cell?.controlSize = .small
		// btn.bezelStyle = .inline                  // Deprecated?
		btn.cell?.isBezeled = true                   // Closest property I can find.
		// btn.cell?.setButtonType(.momentaryPushIn) // Deprecated?
		btn.setButtonType(.momentaryPushIn)
		btn.cell?.font = NSFont.boldSystemFont(ofSize: 10)
		btn.cell?.alignment = .center

		self.imageView = iv
		self.textField = tf
		self.addSubview(iv)
		self.addSubview(tf)
		self.addSubview(btn)
	}

	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var button: NSButton {
		get {
			return self.subviews[2] as! NSButton
		}
	}
}

extension FileListingViewController: NSOutlineViewDelegate {
	
	func outlineView(_ outlineView: NSOutlineView,
					 viewFor tableColumn: NSTableColumn?,
					 item: Any) -> NSView? {
		var cell: NSTableCellView?
		
		cell = NSTableCellView()
		cell?.wantsLayer = true
		cell?.layer?.backgroundColor = .init(
			red: .random(in: 0...1),
			green: .random(in: 0...1),
			blue: .random(in: 0...1),
			alpha: 1
		)
	
		
		return cell
	}
	
}


