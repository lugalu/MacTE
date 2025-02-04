//Created by Lugalu on 03/02/25.

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let rect = NSRect(origin: .zero, size: NSScreen.main!.frame.size)
		
		let window = NSWindow(
			contentRect: rect,
			styleMask: [.titled, .closable, .resizable, .miniaturizable],
			backing: .buffered,
			defer: false
		)
		window.title = "Test"
		let vc = MainSplitViewController()
		window.contentViewController = vc
		window.makeKeyAndOrderFront(nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}


}
