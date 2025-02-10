//Created by Lugalu on 03/02/25.

import AppKit

class MainSplitViewController: NSSplitViewController {
	lazy var itemA: NSSplitViewItem = NSSplitViewItem()
	lazy var itemB: NSSplitViewItem = NSSplitViewItem()
	
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		self.splitView.dividerStyle = .paneSplitter
		
		let vcA = NSViewController()
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
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

class FileListingViewController: NSTreeController{
	
//	override func viewDidLoad() {
//		self.view = NSOutlineView()
//	}
}
