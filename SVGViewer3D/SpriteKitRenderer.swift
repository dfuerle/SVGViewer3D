//
//  SpriteKitRenderer.swift
//  SVGViewer3D
//
//  Created by Dmitri Fuerle on 10/27/14.
//  Copyright (c) 2014 Dmitri Fuerle. All rights reserved.
//

import Foundation
import SpriteKit

@objc(DFSpriteKitRenderer) class SpriteKitRenderer : NSObject, SVGParserDelegate {

	func svg(width: CFloat, height: CFloat) {
		
	}
	
	func square(x: CFloat, y: CFloat, width: CGFloat, height: CGFloat, length: CGFloat, fill: UIColor?, stroke: UIColor?) {
		
	}
	
	func polygon(path: UIBezierPath, extrusionDepth: CGFloat, fill: UIColor?, stroke: UIColor?) {
		
	}
	
	func circle(x: Float32, y: Float32, radius: Float32, fill: UIColor) {
		
	}
	
	func text(matrix: transformMatrix, text: String, fontFamily: String, fontSize: CGFloat, fill: UIColor) {
		
	}
}