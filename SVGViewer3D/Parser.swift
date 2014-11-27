//
//  SVGParser.swift
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

struct transformMatrix {
    var first:CFloat = 0.0
    var second:CFloat = 0.0
    var third:CFloat = 0.0
    var fourth:CFloat = 0.0
    var x:CFloat = 0.0
    var y:CFloat = 0.0
}

protocol SVGParserDelegate {
    func svg(width: CFloat, height: CFloat)
    func square(x: CFloat, y: CFloat, width: CGFloat, height: CGFloat, length: CGFloat, fill: UIColor?, stroke: UIColor?)
    func polygon(path: UIBezierPath, extrusionDepth: CGFloat, fill: UIColor?, stroke: UIColor?)
    func circle(x: Float32, y: Float32, radius: Float32, fill: UIColor)
    func text(matrix: transformMatrix, text: String, fontFamily: String, fontSize: CGFloat, fill: UIColor)
}

class SVGParser : NSObject, NSXMLParserDelegate {

    let factor: CFloat = 1
    
    var divDict: NSDictionary?
    var divCharacters: NSMutableString?
    
    var groupIdentifier: String?
    
    var delegate: SVGParserDelegate
    
    init(delegate:SVGParserDelegate) {
        self.delegate = delegate
        
        super.init()
    }
    
    // Public method to load a zone
    func parse(fromFileURL fileURL:NSURL) {
        
        let parser = NSXMLParser(contentsOfURL: fileURL)
        parser!.delegate = self;
        parser!.parse()
    }

    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!) {
		
        if elementName == "svg" {
            let width: CFloat = attributeDict.floatValue("width") * factor
            let height: CFloat = attributeDict.floatValue("height") * factor
            self.delegate.svg(width, height: height)
        }
        else if elementName == "g" {
            self.groupIdentifier = attributeDict["id"] as? String
        }
        else if elementName == "rect" {
            var lenth: CGFloat = 0
                        
            var x: CFloat = attributeDict.floatValue("x") * factor
            var y: CFloat = attributeDict.floatValue("y") * factor * -1
            let fill: UIColor? = attributeDict.colorValue("fill")
            let stroke: UIColor? = attributeDict.colorValue("stroke")
            let width = CGFloat(attributeDict.floatValue("width") * factor)
            let height = CGFloat(attributeDict.floatValue("height") * factor)
            self.delegate.square(x, y: y, width: width, height: height, length: lenth, fill: fill, stroke: stroke)
        }
        else if elementName == "polygon" {
            let fill: UIColor? = attributeDict.colorValue("fill")
            let stroke: UIColor? = attributeDict.colorValue("stroke")
            let path = attributeDict.bezierPathValue("points", factor:factor)
            self.delegate.polygon(path!, extrusionDepth: 0.0, fill: fill, stroke: stroke)
        }
        else if elementName == "path" {
			let fill: UIColor? = attributeDict.colorValue("fill")
			let stroke: UIColor? = attributeDict.colorValue("stroke")
			let strokeWidth: CGFloat = CGFloat(attributeDict.floatValue("stroke-width") * factor)
			if let path = attributeDict.bezierPathValue("d", factor: factor) {
				path.lineWidth = strokeWidth
				self.delegate.polygon(path, extrusionDepth: 0.0, fill: fill, stroke:stroke)
			}
        }
        else if elementName == "line" {
            let stroke: UIColor? = attributeDict.colorValue("stroke")
            let strokeWidth: CGFloat = CGFloat(attributeDict.floatValue("stroke-width") * factor)
            let x1: CGFloat = CGFloat(attributeDict.floatValue("x1") * factor)
            let x2: CGFloat = CGFloat(attributeDict.floatValue("x2") * factor)
            let y1: CGFloat = CGFloat(attributeDict.floatValue("y1") * factor * -1)
            let y2: CGFloat = CGFloat(attributeDict.floatValue("y2") * factor * -1)
            
            let path = UIBezierPath()
            path.lineWidth = strokeWidth
            path.moveToPoint(CGPointMake(x1, y1))
            path.addLineToPoint(CGPointMake(x2, y2))
            path.closePath()
            
            self.delegate.polygon(path, extrusionDepth: 0.0, fill: nil, stroke:stroke)
        }
        else if elementName == "polyline" {
            let stroke: UIColor? = attributeDict.colorValue("stroke")
            let strokeWidth: CGFloat = CGFloat(attributeDict.floatValue("stroke-width") * factor)
			if let path = attributeDict.bezierPathValue("points", factor:factor) {
				path.lineWidth = strokeWidth
				self.delegate.polygon(path, extrusionDepth: 0.0, fill: nil, stroke:stroke)
			}
        }
        else if elementName == "circle" {
            var x: Float32 = attributeDict.floatValue("x") * factor
            var y: Float32 = attributeDict.floatValue("y") * factor * -1
            let fill: UIColor? = attributeDict.colorValue("fill")
            let r: Float32 = attributeDict.floatValue("r") * factor
            
            if let fillColor = fill? {
                self.delegate.circle(x, y: y, radius: r, fill: fillColor)
            }
        }
        else if elementName == "text" {
            self.divCharacters = NSMutableString()
            self.divDict = attributeDict;
        }
        else if elementName == "tspan" {
        }
        else {
            println("elementName \(elementName) attributes \(attributeDict)")
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        if let divCharacters = self.divCharacters {
            divCharacters.appendString(string)
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        if elementName == "g" {
            self.groupIdentifier = nil
        }
        else if elementName == "text" {
            if let attributeDict = self.divDict? {
                
                let fontFamily = attributeDict.stringValue("font-family")
                let fontSize:CGFloat = CGFloat(attributeDict.floatValue("font-size")) * CGFloat(factor)
                var matrixValue:transformMatrix = attributeDict.matrixValue("transform", factor: factor)
                let fill: UIColor? = attributeDict.colorValue("fill")
                
                if let fillColor = fill? {
                    self.delegate.text(matrixValue, text:self.divCharacters!, fontFamily: fontFamily, fontSize: fontSize, fill: fillColor)
                }
                
                self.divCharacters = nil;
                self.divDict = nil;
            }
        }
    }
}