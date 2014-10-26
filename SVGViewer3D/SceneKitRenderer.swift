//
//  Scene.swift
//  dfsvg
//
//  Created by Dmitri Fuerle.
//  Copyright (c) 2014 Dmitri Fuerle. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import OpenGLES

@objc(DFSceneKitRenderer) class SceneKitRenderer : NSObject, MapParserDelegate, SCNSceneRendererDelegate, SCNNodeRendererDelegate {
	
	let factor: CFloat = 0.001
	var renderingOrder = 1
    
    var cameraNode = SCNNode()
    
	var rootNode = SCNNode()
    
	var token: dispatch_once_t = 0
	
    func svg(width: CFloat, height: CFloat) {
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: width/2, y: -height/2, z: 5)
    }

	// create a 3d box
    func square(x: CFloat, y: CFloat, width: CGFloat, height: CGFloat, length: CGFloat, fill: UIColor?, stroke: UIColor?) {
		
		println("square")
		let geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
		let rectNode = SCNNode(geometry: geometry)
		let adjustedX:CFloat = x + CFloat(width) * 0.5
		let adjustedY:CFloat = y - CFloat(height) * 0.5
		let adjustedZ:CFloat = CFloat(length) * 0.5
		rectNode.position = SCNVector3Make(adjustedX, adjustedY, adjustedZ);
		geometry.firstMaterial = self.materialForColor(fill!)
        self.addNode(rectNode)
        
//        if let strokeColor = stroke {
//            let cgPoints:[CGPoint] = [
//                CGPointMake(x - width, y - height),
//                CGPointMake(x - width, y + height),
//                CGPointMake(x + width, y - height),
//                CGPointMake(x + width, y + height)
//            ]
//            linePolygon(cgPoints, strokeColor: strokeColor)
//        }
    }
    
    // Draw a line polygon
    func linePolygon(cgPoints: [CGPoint], strokeColor: UIColor) {
		
		println("linePolygon")
        var vertices: [SCNVector3] = []
        var indicies: [UInt32] = []
        
        var index:UInt32 = 0
        for point:CGPoint in cgPoints {
            let ventor3 = SCNVector3Make(CFloat(point.x), CFloat(point.y), 0.0)
            vertices.append(ventor3)
            indicies.append(index)
            index = index + 1
        }
        
        let vertexSoure = SCNGeometrySource(vertices: &vertices, count: vertices.count)
        let data = NSData(bytes: indicies, length: sizeof(UInt32) * indicies.count)
        let element = SCNGeometryElement(data: data, primitiveType: .Line, primitiveCount: cgPoints.count - 1, bytesPerIndex: sizeof(UInt32))
        let geometry = SCNGeometry(sources: [vertexSoure], elements: [element])
        geometry.firstMaterial = self.materialForColor(strokeColor)
        let lineNode = SCNNode(geometry: geometry)
        self.addNode(lineNode)
    }
    
	// Create a 3d shape
    func polygon(path: UIBezierPath, extrusionDepth: CGFloat, fill: UIColor?, stroke: UIColor?) {
		
		println("polygon")
        if let fillColor = fill {
            let geometry = SCNShape(path: path, extrusionDepth: 0.0)
            let rectNode = SCNNode(geometry: geometry)
            geometry.firstMaterial = self.materialForColor(fillColor)
            self.addNode(rectNode)
        }
		if let strokeColor = stroke {
		}
	}
	
	// Create a Circle
    func circle(x: Float32, y: Float32, radius: Float32, fill: UIColor) {
		
		println("circle")
		let geometry = SCNCylinder(radius: CGFloat(radius), height: 0.0)
		let circleNode = SCNNode(geometry: geometry)
		let adjustedX:CFloat = x + CFloat(radius) * 0.5
		let adjustedY:CFloat = y - CFloat(radius) * 0.5
		circleNode.position = SCNVector3Make(adjustedX, adjustedY, 0.0);
		geometry.firstMaterial = self.materialForColor(fill)
        self.addNode(circleNode)
	}
	
	// Draw text
    func text(matrix: transformMatrix, text: String, fontFamily: String, fontSize: CGFloat, fill: UIColor) {
		
		println("text")
		let geometry = SCNText(string: text, extrusionDepth: 0.0)
		geometry.firstMaterial = self.materialForColor(fill)
		geometry.font = UIFont(name: fontFamily, size: fontSize)
		let textNode = SCNNode(geometry: geometry)
		textNode.position = SCNVector3Make(matrix.x, matrix.y, 0.0)
		textNode.transform = SCNMatrix4Scale(textNode.transform, 0.01, 0.01, 0.01)
//		textNode.constraints = [SCNLookAtConstraint(target: self.cameraNode)]
		self.addNode(textNode)
	}
	
	// Obtain material for color - reused
	func materialForColor(color: UIColor) -> SCNMaterial {
		let material = SCNMaterial()
		let materialProperty = material.diffuse
		materialProperty.contents = color
		material.writesToDepthBuffer = false
		return material
	}
	
	func addNode(node: SCNNode) {
		node.castsShadow = false
		node.renderingOrder = renderingOrder
		renderingOrder = renderingOrder + 1
		rootNode.addChildNode(node)
	}
}