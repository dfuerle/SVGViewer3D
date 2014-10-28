//
//  SpriteKitRenderer.swift
//  SVGViewer3D
//
//  Created by Dmitri Fuerle on 10/27/14.
//  Copyright (c) 2014 Dmitri Fuerle. All rights reserved.
//

import Foundation
import SpriteKit

@objc(DFSpriteKitRenderer) class SpriteKitRenderer : SKView, SVGParserDelegate {
	
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
	}

	// MARK: SVGParserDelegate

	func svg(width: CFloat, height: CFloat) {
		
		// Create and configure the scene.
		let scene = SKScene(size: CGSizeMake(CGFloat(width), CGFloat(height)))
		scene.scaleMode = SKSceneScaleMode.AspectFill
		scene.addChild(self.rootNode)
		scene.addChild(self.cameraNode)
		self.cameraNode.name = "camera"
		
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
//		self.scene!.addChild(polygon)
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