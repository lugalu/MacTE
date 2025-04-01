//Created by Lugalu on 03/02/25.

import AppKit

protocol SplitViewDelegate {
	func didSelectFile(_ url: URL)
}

class SplitViewController: NSSplitViewController, SplitViewDelegate {
	lazy var fileSelectionItem: NSSplitViewItem = NSSplitViewItem()
	lazy var textfieldItem: NSSplitViewItem = NSSplitViewItem()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		self.splitView.dividerStyle = .paneSplitter
		
		let fileSidebar = FileListingViewController(delegate: self)
		fileSidebar.view.wantsLayer = true
		fileSidebar.view.layer?.backgroundColor = NSColor.secondarySystemFill.cgColor
		
		let textfieldVC = TextFieldViewController()
		textfieldVC.view.wantsLayer = true
		textfieldVC.view.layer?.backgroundColor = .init(
			red: 0,
			green: 0,
			blue: 1,
			alpha: 1
		)
		
		fileSelectionItem = NSSplitViewItem(sidebarWithViewController: fileSidebar)
		fileSelectionItem.minimumThickness = 200
		fileSelectionItem.maximumThickness = 300
		fileSelectionItem.allowsFullHeightLayout = true
		fileSelectionItem.preferredThicknessFraction = 0.2
		
		textfieldItem = NSSplitViewItem(contentListWithViewController: textfieldVC)
		textfieldItem.canCollapse = false
		textfieldItem.holdingPriority = .defaultLow
		
		addSplitViewItem(fileSelectionItem)
		addSplitViewItem(textfieldItem)
	}
	
	@objc func toggleSidebar() {
		fileSelectionItem.isCollapsed.toggle()
	}
	
	func didSelectFile(_ url: URL) {
		guard
			let vc = textfieldItem.viewController as? TextFieldViewController
		else { return }
		
		vc.loadFile(with: url)
	}
	
}




