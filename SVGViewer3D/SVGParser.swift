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

extension SCNVector3 : Printable {
    public var description: String { return "x:\(self.x) y:\(self.y) z:\(self.z)" }
}

/*
func +<T: ForwardIndex>(var index: T, var count: Int) -> T {
    for (; count > 0; --count) {
        index = index.successor()
    }
    return index
}
*/

struct transformMatrix {
    var first:CFloat = 0.0
    var second:CFloat = 0.0
    var third:CFloat = 0.0
    var fourth:CFloat = 0.0
    var x:CFloat = 0.0
    var y:CFloat = 0.0
}

extension NSDictionary {
    
    func stringValue(name: String, notFoundValue:String = "") -> String {
        let valueString = (self[name] as? String)
        if (valueString != nil) {
            return valueString!
        }
        else {
            return notFoundValue
        }
    }
    
    func floatValue(name: String) -> CFloat {
        var value: CFloat = 0
        let valueString = (self[name] as? String)
        if (valueString != nil) {
            value = valueString!.floatValue()
        }
        return value
    }
    
    func colorValue(name: String) -> UIColor? {
        var value: UIColor?
        let valueString = (self[name] as? String)
        if (valueString != nil) {
            value = valueString!.colorValue()
        }
        return value
    }
    
    func pointsValue(name: String, factor: CFloat) -> [CGPoint] {
        var value: [CGPoint] = []
        let valueString = (self[name] as? String)
        if (valueString != nil) {
            let points = valueString!.componentsSeparatedByString(" ")
            for twoPoint in points {
                let cleanedTwoPoint = twoPoint.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range:nil)
                if cleanedTwoPoint.isEmpty == false {
                    let xy = cleanedTwoPoint.componentsSeparatedByString(",")
                    if xy.count == 2 {
                        let x = xy[0].floatValue() * factor
                        let y = xy[1].floatValue() * factor * -1
                        let point = CGPointMake(CGFloat(x),CGFloat(y))
                        value.append(point)
                    }
                }
            }
        }
        return value
    }
    
    func bezierPathValue(name: String, factor: CFloat) -> UIBezierPath {
        let points = self.pointsValue(name, factor:factor)
        
        let path = UIBezierPath()
        var firstItem = true
        for point in points {
            if firstItem == true {
                path.moveToPoint(point)
                firstItem = false
            }
            else {
                path.addLineToPoint(point)
            }
        }
        path.closePath()
        
        return path
    }
    
    // http://tutorials.jenkov.com/svg/path-element.html
    // M2679.5,816.2v-17.5l32.5-32.5h113.5l32.5,32.5v17.5l-32.5,32.5   H2712L2679.5,816.2z
    func pathValue(name: String, factor: CFloat) -> UIBezierPath {
        let path = UIBezierPath()
        //        let valueString = (self[name] as? String)
        //        if let pathString = valueString {
        //            let characterSet = NSCharacterSet(charactersInString: "mlhvcsqtaz")
        //            let aScanner = NSScanner(string: pathString.lowercaseString)
        //            var testString:NSString?
        //            aScanner.scanUpToCharactersFromSet(characterSet, intoString: &testString)
        //            if let direction = testString {
        //                let firstCharacter = direction.characterAtIndex(0)
        //                switch firstCharacter {
        //                case "m":
        //                    // Move
        //                    let numbers = testString.componentsSeparatedByString(",")
        ////                case "l":
        //                    // Move
        //                }
        //            }
        //        }
        //        path.closePath()
        
        return path
    }
    
    func matrixValue(name: String, factor:CFloat) -> transformMatrix {
        let valueString = (self[name] as? String)
        if let valueUnwrapped: String = valueString? {
            let start:String.Index = advance(valueUnwrapped.startIndex, 7) // matrix(
            let end:String.Index = valueUnwrapped.endIndex
            let numberString = valueUnwrapped.substringWithRange(Range<String.Index> (start: start,end: end))
            let numbers = numberString.componentsSeparatedByString(" ")
            
            let matrix:transformMatrix = transformMatrix(
                first: numbers[0].cfloatValue(),
                second: numbers[1].cfloatValue(),
                third: numbers[2].cfloatValue(),
                fourth: numbers[3].cfloatValue(),
                x: numbers[4].cfloatValue() * factor,
                y: numbers[5].cfloatValue() * factor * -1)
            
            return matrix
        }
        
        return transformMatrix(first: 0, second: 0, third: 0, fourth: 0, x: 0, y: 0)
    }
}

extension String {
    func floatValue() -> Float32 {
        return Float32(self.cfloatValue())
    }
    
    func cfloatValue() -> CFloat {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let number = numberFormatter.numberFromString(self.stringByTrimmingCharactersInSet(characterSet))
        if (number != nil) {
            return number!.floatValue
        }
        return 0
    }
    
    func colorValue () -> UIColor {
        var cString:String = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (countElements(cString) != 6) {
            return UIColor.grayColor()
        }
		
		let indexAt2 = advance(cString.startIndex, 2)
		let indexAt4 = advance(indexAt2, 2)
		let indexAt6 = advance(indexAt4, 2)
		
        var rString = cString.substringToIndex(indexAt2)
        var gString = cString.substringWithRange(indexAt2..<indexAt4)
        var bString = cString.substringWithRange(indexAt4..<indexAt6)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner.localizedScannerWithString(rString).scanHexInt(&r)
        NSScanner.localizedScannerWithString(gString).scanHexInt(&g)
        NSScanner.localizedScannerWithString(bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

protocol MapParserDelegate {
    func svg(width: CFloat, height: CFloat)
    func square(x: CFloat, y: CFloat, width: CGFloat, height: CGFloat, length: CGFloat, fill: UIColor?, stroke: UIColor?)
    func polygon(path: UIBezierPath, extrusionDepth: CGFloat, fill: UIColor?, stroke: UIColor?)
    func circle(x: Float32, y: Float32, radius: Float32, fill: UIColor)
    func text(matrix: transformMatrix, text: String, fontFamily: String, fontSize: CGFloat, fill: UIColor)
}

@objc(DFSVGParser) class SVGParser : NSObject, NSXMLParserDelegate {

    let factor: CFloat = 0.001
    
    var divDict: NSDictionary?
    var divCharacters: NSMutableString?
    
    var groupIdentifier: String?
    
    var delegate: MapParserDelegate
    
    init(delegate:SceneKitRenderer) {
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
            self.delegate.polygon(path, extrusionDepth: 0.0, fill: fill, stroke: stroke)
        }
        else if elementName == "path" {
            let fill: UIColor? = attributeDict.colorValue("fill")
            let d = attributeDict.pathValue("d", factor: factor)
        }
        else if elementName == "line" {
            let stroke: UIColor? = attributeDict.colorValue("stroke")
            let strokeWidth: CGFloat = CGFloat(attributeDict.floatValue("stroke-width") * factor)
            let x1: CGFloat = CGFloat(attributeDict.floatValue("x1") * factor)
            let x2: CGFloat = CGFloat(attributeDict.floatValue("x2") * factor)
            let y1: CGFloat = CGFloat(attributeDict.floatValue("y1") * factor)
            let y2: CGFloat = CGFloat(attributeDict.floatValue("y2") * factor)
            
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
            let path = attributeDict.bezierPathValue("points", factor:factor)
            path.lineWidth = strokeWidth
            
            self.delegate.polygon(path, extrusionDepth: 0.0, fill: nil, stroke:stroke)
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