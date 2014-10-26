//
//  SVGViewer.swift
//  dfsvg
//
//  Created by Dmitri Fuerle.
//  Copyright (c) 2014 Dmitri Fuerle. All rights reserved.
//

import UIKit
import SceneKit
import QuartzCore

@objc(DFSVGViewer) class SVGViewer: SCNView {

/*
	@IBInspectable var integer: Int = 0
	@IBInspectable var float: CGFloat = 0
	@IBInspectable var double: Double = 0
	@IBInspectable var point: CGPoint = CGPointZero
	@IBInspectable var size: CGSize = CGSizeZero
	@IBInspectable var customFrame: CGRect = CGRectZero
	@IBInspectable var color: UIColor = UIColor.clearColor()
	@IBInspectable var string: String = "We ❤ Swift"
	@IBInspectable var bool: Bool = false
	
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
	
	@IBInspectable var borderColor: UIColor = UIColor.clearColor() {
		didSet {
			layer.borderColor = borderColor.CGColor
		}
	}
	
	@IBInspectable var borderWidth: CGFloat = 0 {
		didSet {
			layer.borderWidth = borderWidth
		}
	}
	
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet {
			layer.cornerRadius = cornerRadius
		}
	}
*/
	func loadSVG(fromFileURL fileURL:NSURL) {
		// create a new scene
		let scene = SCNScene()
		
		// retrieve the SCNView
		let scnView = self
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true

		let renderer = SceneKitRenderer()
		let parser = SVGParser(delegate:renderer)
		parser.parse(fromFileURL: fileURL)
		scene.rootNode.addChildNode(renderer.rootNode)
		println("rootnode \(renderer.rootNode)")
		scene.rootNode.addChildNode(renderer.cameraNode)
		println("camera \(renderer.cameraNode)")
	}
}
