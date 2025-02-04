//Created by Lugalu on 03/02/25.

import Cocoa

class MainSplitViewController: NSSplitViewController {
	lazy var itemA: NSSplitViewItem = NSSplitViewItem()
	lazy var itemB: NSSplitViewItem = NSSplitViewItem()

	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		self.splitView.dividerStyle = .paneSplitter
		
		let vcA = NSViewController()
		vcA.view.wantsLayer = true
		vcA.view.layer?.backgroundColor = .init(
			red: 1,
			green: 0,
			blue: 0,
			alpha: 1
		)
		
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

		let btn = NSButton(
			image: NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)!,
			target: self,
			action: #selector(test)
		)
		btn.translatesAutoresizingMaskIntoConstraints = false
		
		vcB.view.addSubview(btn)
		
		let constraints = [
			btn.topAnchor.constraint(equalTo: vcB.view.topAnchor, constant: 8),
			btn.leadingAnchor
				.constraint(equalTo: vcB.view.leadingAnchor, constant: 8),
			btn.widthAnchor.constraint(equalToConstant: 200),
			btn.heightAnchor.constraint(equalToConstant: 100)
		]
		
		NSLayoutConstraint.activate(constraints)
	}

	@objc func test() {
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
