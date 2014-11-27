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
import SVGViewer

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
		let path = NSBundle.mainBundle().pathForResource("test", ofType: "svg")
		let url = NSURL(fileURLWithPath: path!)

		let startTime = CFAbsoluteTimeGetCurrent()

//		if self.view is SceneKitRenderer {
//			let svgViewer = self.view as SceneKitRenderer
//			svgViewer.loadSVG(fromFileURL: url!)
//		}

		if self.view is SpriteKitRenderer {
			let svgViewer = self.view as SpriteKitRenderer
			svgViewer.loadSVG(fromFileURL: url!)
		}

		let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
		println("Time elapsed for loadSVG: \(timeElapsed) s")
    }
}
