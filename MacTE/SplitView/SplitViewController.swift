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

		
		let test = NSOpenPanel()
		test.canChooseFiles = true
		test.canChooseDirectories = true
		test.allowsMultipleSelection = true
		test.allowedContentTypes = [.text, .sourceCode, .folder]
		
		test.begin { [weak self] response in
			guard response == .OK, let self else { return }
			for url in test.urls {
				let name = (url.absoluteString as NSString).lastPathComponent
				guard let isDirectory = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory else {
					return
				}
				var node: FileSystemNode
				if isDirectory {
					node = FileSystemNode(name: name, type: .folder, url: url)
					self.addChilden(for: node)
				}else {
					let components = name.components(separatedBy: ".")
					guard let name = components.first, let fileExtension = components.last else {
						continue
					}
					node = FileSystemNode(
						name: name,
						type: .file(fileExtension: fileExtension),
						url: url
					)
				}
				
				self.add(node: node)
//				self.scrollView.contentView.addSubview(outlineView)
			}
		}

	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
	}
	
	func addChilden(for node: FileSystemNode) {
		let url = node.url
		guard let enumerator = FileManager.default.enumerator(
			at: node.url,
			includingPropertiesForKeys: [.isRegularFileKey],
			options: [
				.skipsHiddenFiles,
				.skipsPackageDescendants,
				.skipsSubdirectoryDescendants
			]
		) else {
			return
		}
		
		
		for case let fileURL as URL in enumerator {
			guard let fileAttributes = try? fileURL.resourceValues(
				forKeys:[.isDirectoryKey, .nameKey]),
				  let isDirectory = fileAttributes.isDirectory,
				  let name = fileAttributes.name
			else { continue }
			
			var childNode: FileSystemNode
			if isDirectory {
				childNode = FileSystemNode(
					name: name,
					type: .folder,
					url: fileURL
				)
				addChilden(for: childNode)
				
			}else {
				let components = name.components(separatedBy: ".")
				guard let name = components.first, let fileExtension = components.last else {
					continue
				}
				childNode = FileSystemNode(
					name: name,
					type: .file(fileExtension: fileExtension),
					url: fileURL
				)
			}
			
			node.children.append(childNode)
		}
		
	}
	
	
	fileprivate func addOutlineView() {
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
