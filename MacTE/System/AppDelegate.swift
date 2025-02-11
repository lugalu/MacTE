//Created by Lugalu on 03/02/25.

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSToolbarItemValidation {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let rect = NSRect(origin: .zero, size: NSScreen.main!.frame.size)
		
		let window = NSWindow(
			contentRect: rect,
			styleMask: [.titled, .closable, .resizable, .miniaturizable],
			backing: .buffered,
			defer: false
		)
		window.title = "Test"
		
		makeToolbar(for: window)
		
		let vc = SplitViewController()
		window.contentViewController = vc
		window.makeKeyAndOrderFront(nil)
	}
	
	func makeToolbar(for window: NSWindow) {
		let toolbar = NSToolbar(
			identifier: NSToolbar.Identifier.TextEditorIdentifier
		)
		toolbar.delegate = self
		window.toolbar = toolbar
		window.toolbar?.validateVisibleItems()
		window.toolbarStyle = .unifiedCompact
	}
	
	func validateToolbarItem(_ item: NSToolbarItem) -> Bool { true }

	func applicationWillTerminate(_ aNotification: Notification) {}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }


}

extension AppDelegate: NSToolbarDelegate {
	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		let group = NSToolbarItemGroup(
			itemIdentifier: NSToolbarItem.Identifier.toggleSidebar,
			titles: [],
			selectionMode: .selectOne,
			labels: .none,
			target: nil,
			action: #selector(NSSplitViewController.toggleSidebar)
		)
		return group
	}
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [
			NSToolbarItem.Identifier.toggleSidebar
		]
	}
	
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [
			NSToolbarItem.Identifier.toggleSidebar
		]
	}
	
	func toolbarWillAddItem(_ notification: Notification) {}
	
	func toolbarDidRemoveItem(_ notification: Notification) {}
	
	func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] { [] }
}
