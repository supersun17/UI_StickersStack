//
//  ViewController.swift
//  UI_StickersStack
//
//  Created by sunming@udel.edu on 05/17/2019.
//  Copyright (c) 2019 sunming@udel.edu. All rights reserved.
//

import UIKit
import UI_StickersStack

class ViewController: UIViewController {
	@IBOutlet weak var stickersStack: StickersStack!

	var colorList: [UIColor] = [.blue,.blue,.blue,.blue,.blue,.blue,.blue]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

		setupStickersStack()
		stickersStack.reloadStack()
    }

	@IBAction func addButton(_ sender: UIButton) {
		colorList.append(UIColor.red)
		stickersStack.addNewSticker()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: StickersStackDataSource {
	func setupStickersStack() {
		stickersStack.dataSource = self
	}

	func numberOfStickers() -> Int {
		return colorList.count
	}

	func contentViewForSticker(at index: Int) -> UIView {
		let view = UIView()
		view.backgroundColor = colorList[index]
		return view
	}
}
