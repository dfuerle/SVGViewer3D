//
//  GameViewController.swift
//  sampleSVGViewer
//
//  Created by Dmitri Fuerle on 7/13/14.
//  Copyright (c) 2014 Dmitri Fuerle. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
		let path = NSBundle.mainBundle().pathForResource("test", ofType: "svg")
		let url = NSURL(fileURLWithPath: path!)
		if self.view is SVGViewer {
			let svgViewer = self.view as SVGViewer
			svgViewer.loadSVG(fromFileURL: url!)
		}
    }
}
