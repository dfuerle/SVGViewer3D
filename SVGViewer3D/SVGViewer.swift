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

@objc(DFSVGViewer) class SVGViewer: SCNView, UIGestureRecognizerDelegate {

	var cameraNode: SCNNode?

	@IBInspectable var integer: Int = 0
	@IBInspectable var float: CGFloat = 0
	@IBInspectable var double: Double = 0
	@IBInspectable var point: CGPoint = CGPointZero
	@IBInspectable var size: CGSize = CGSizeZero
	@IBInspectable var customFrame: CGRect = CGRectZero
	@IBInspectable var color: UIColor = UIColor.clearColor()
	@IBInspectable var string: String = "We ❤ Swift"
	@IBInspectable var bool: Bool = false
	
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
	
	func loadSVG(fromFileURL fileURL:NSURL) {
		// create a new scene
		let scene = SCNScene()
		
		// retrieve the SCNView
		let scnView = self
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		//scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true

		let renderer = SceneKitRenderer()
		let parser = SVGParser(delegate:renderer)
		parser.parse(fromFileURL: fileURL)
		scene.rootNode.addChildNode(renderer.rootNode)
		println("rootnode \(renderer.rootNode)")
		scene.rootNode.addChildNode(renderer.cameraNode)
		self.cameraNode = renderer.cameraNode
		println("camera \(renderer.cameraNode)")
		
		// Gestures
		let tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
		tapRecognizer.delegate = self
		self.addGestureRecognizer(tapRecognizer)
		
		let panRecognizer = UIPanGestureRecognizer(target: self, action:Selector("handlePan:"))
		panRecognizer.delegate = self
		self.addGestureRecognizer(panRecognizer)
		
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:Selector("handlePinch:"))
		pinchRecognizer.delegate = self
		self.addGestureRecognizer(pinchRecognizer)

		let rotateRecognizer = UIRotationGestureRecognizer(target: self, action:Selector("handleRotate:"))
		rotateRecognizer.delegate = self
		self.addGestureRecognizer(rotateRecognizer)
	}
	
	func handleTap(recognizer: UITapGestureRecognizer) {
		let position:SCNVector3 = self.cameraNode!.position
		
		UIView.animateWithDuration(2,
			delay: 0,
			options: UIViewAnimationOptions.CurveEaseOut,
			animations: {
				self.cameraNode!.position = SCNVector3Make(position.x, position.y, 1)
			},
			completion: nil)
	}
	
	@IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
		let translation = recognizer.translationInView(self)
		let position:SCNVector3 = self.cameraNode!.position
		self.cameraNode!.position = SCNVector3Make(position.x + Float(translation.x) * -0.01, position.y + Float(translation.y) * 0.01, position.z)
		recognizer.setTranslation(CGPointZero, inView: self)
	}
	
	@IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
		recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform,
			recognizer.scale, recognizer.scale)
		recognizer.scale = 1
	}
 
	@IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
		recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
		recognizer.rotation = 0
	}
	
	func gestureRecognizer(UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
		return true
	}
}
