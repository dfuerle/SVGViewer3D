//
//  SpriteKitRenderer.swift
//  SVGViewer3D
//
//  Created by Dmitri Fuerle on 10/27/14.
//  Copyright (c) 2014 Dmitri Fuerle. All rights reserved.
//

import Foundation
import SpriteKit

@objc(DFSpriteKitRenderer) class SpriteKitRenderer : SKView, UIGestureRecognizerDelegate, SVGParserDelegate {
	
	var cameraNode = SKNode()
	
	var rootNode = SKNode()

	// MARK: IBInspectable
	
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
	
	// MARK: Public Methods
	
	func loadSVG(fromFileURL fileURL:NSURL) {
		self.showsFPS = true
		self.showsNodeCount = true
		
		let parser = SVGParser(delegate:self)
		parser.parse(fromFileURL: fileURL)
		
		// Gestures
		let tapRecognizer = UITapGestureRecognizer(target: self,
			action:Selector("handleTap:"))
		tapRecognizer.delegate = self
		self.addGestureRecognizer(tapRecognizer)
		
		let panRecognizer = UIPanGestureRecognizer(target: self,
			action:Selector("handlePan:"))
		panRecognizer.delegate = self
		self.addGestureRecognizer(panRecognizer)
		
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:Selector("handlePinch:"))
		pinchRecognizer.delegate = self
		self.addGestureRecognizer(pinchRecognizer)
		
		let rotateRecognizer = UIRotationGestureRecognizer(target: self, action:Selector("handleRotate:"))
		rotateRecognizer.delegate = self
		self.addGestureRecognizer(rotateRecognizer)
	}

	// MARK: Actions
	
	@IBAction func handleTap(recognizer: UITapGestureRecognizer) {
	}
	
	@IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
		let translation = recognizer.translationInView(self)
		let position = self.cameraNode.position
		self.cameraNode.position = CGPointMake(position.x + translation.x * -0.01, position.y + translation.y * 0.01)
		recognizer.setTranslation(CGPointZero, inView: self)
	}
	
	@IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
		recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
		recognizer.scale = 1
	}
 
	@IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
		recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
		recognizer.rotation = 0
	}
	
	// MARK: UIGestureRecognizerDelegate
	
	func gestureRecognizer(UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
		return true
	}
	
	// MARK: SVGParserDelegate

	func svg(width: CFloat, height: CFloat) {
		
		// Create and configure the scene.
		let scene = RendererScene(size: CGSizeMake(CGFloat(width*3), CGFloat(height*3)))
		scene.scaleMode = SKSceneScaleMode.AspectFill
		scene.addChild(self.rootNode)
		self.rootNode.addChild(self.cameraNode)
		scene.anchorPoint = CGPointMake(0.5, 0.5)
		self.cameraNode.name = "camera"
		self.cameraNode.position = CGPointMake(CGFloat(width)/2, CGFloat(height)/2)
		
		// Present the scene.
		self.presentScene(scene)
	}
	
	func square(x: CFloat, y: CFloat, width: CGFloat, height: CGFloat, length: CGFloat, fill: UIColor?, stroke: UIColor?) {
		let squarePath = UIBezierPath(rect: CGRectMake(CGFloat(x), CGFloat(y), CGFloat(width), CGFloat(height)))
		let square = SKShapeNode(path: squarePath.CGPath)
		if let fillColor = fill {
			square.fillColor = fillColor
		}
		if let strokeColor = stroke {
			square.strokeColor = strokeColor
		}
		self.rootNode.addChild(square)
	}
	
	func polygon(path: UIBezierPath, extrusionDepth: CGFloat, fill: UIColor?, stroke: UIColor?) {
//		let polygon = SKShapeNode(path: path.CGPath)
//		if let fillColor = fill {
//			polygon.fillColor = fillColor
//		}
//		if let strokeColor = stroke {
//			polygon.strokeColor = strokeColor
//		}
//		self.rootNode.addChild(polygon)
	}
	
	func circle(x: Float32, y: Float32, radius: Float32, fill: UIColor) {
		let circlePath = UIBezierPath(ovalInRect: CGRectMake(CGFloat(x), CGFloat(y), CGFloat(radius), CGFloat(radius)))
		let circle = SKShapeNode(path: circlePath.CGPath)
		circle.fillColor = fill
		self.rootNode.addChild(circle)
	}
	
	func text(matrix: transformMatrix, text: String, fontFamily: String, fontSize: CGFloat, fill: UIColor) {
		
	}
}

class RendererScene : SKScene {
	
	override func didFinishUpdate() {
		if let node = self.childNodeWithName("//camera") {
			if let parent = node.parent {
				if let cameraPositionInScene = node.scene?.convertPoint(node.position, fromNode: parent) {
					parent.position = CGPointMake(parent.position.x - cameraPositionInScene.x, parent.position.y - cameraPositionInScene.y);
				}
			}
		}
	}
}
