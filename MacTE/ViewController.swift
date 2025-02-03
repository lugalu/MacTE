//Created by Lugalu on 03/02/25.

import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		view.layer?.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 1)

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

