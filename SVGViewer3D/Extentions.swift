//
//  Extentions.swift
//  SVGViewer3D
//
//  Created by Dmitri Fuerle on 10/26/14.
//  Copyright (c) 2014 Dmitri Fuerle. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension SCNVector3 : Printable {
	public var description: String { return "x:\(self.x) y:\(self.y) z:\(self.z)" }
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
					value.append(cleanedTwoPoint.cgpointValue(factor))
				}
			}
		}
		return value
	}
		
	// http://tutorials.jenkov.com/svg/path-element.html
	// M2679.5,816.2v-17.5l32.5-32.5h113.5l32.5,32.5v17.5l-32.5,32.5   H2712L2679.5,816.2z
	func bezierPathValue(name: String, factor: CFloat) -> UIBezierPath? {
		let valueString = (self[name] as? String)
		if let valueUnwrapped: String = valueString? {
			let path = UIBezierPath()
			let characterSet = NSCharacterSet(charactersInString: "mlhvcsqtazMLHVCSQTAZ")
			let scanner = NSScanner(string: valueUnwrapped)
			var commandObj:NSString?
			var directionObj:NSString?
			var lastPoint:CGPoint = CGPointMake(0, 0)
			while scanner.scanCharactersFromSet(characterSet, intoString: &commandObj) && scanner.scanUpToCharactersFromSet(characterSet, intoString: &directionObj) {
				
				let command = String(commandObj!)
				let direction = String(directionObj!)
				
				switch command {
				case "M": // Move
					lastPoint = direction.cgpointValue(factor)
					path.moveToPoint(lastPoint)
				case "m": // Move (relative)
					let nextPoint = direction.cgpointValue(factor)
					lastPoint = CGPointMake(nextPoint.x + lastPoint.x, nextPoint.y + lastPoint.y)
					path.moveToPoint(lastPoint)
				case "L": // Line
					lastPoint = direction.cgpointValue(factor)
					path.addLineToPoint(lastPoint)
				case "l": // Line (relative)
					let nextPoint = direction.cgpointValue(factor)
					lastPoint = CGPointMake(nextPoint.x + lastPoint.x, nextPoint.y + lastPoint.y)
					path.addLineToPoint(lastPoint)
				case "H": // Horizontal Line
					lastPoint = CGPointMake(direction.cgfloatValue(factor), lastPoint.y)
					path.addLineToPoint(lastPoint)
				case "h": // Horizontal Line (relative)
					lastPoint = CGPointMake(direction.cgfloatValue(factor) + lastPoint.x, lastPoint.y)
					path.addLineToPoint(lastPoint)
				case "V": // Vertical Line
					lastPoint = CGPointMake(lastPoint.x, direction.cgfloatValue(factor) * -1)
					path.addLineToPoint(lastPoint)
				case "v": // Vertical Line (relative)
					lastPoint = CGPointMake(lastPoint.x, direction.cgfloatValue(factor) + lastPoint.y * -1)
					path.addLineToPoint(lastPoint)
				case "C": // Cubic Bezier Curve
					let cgfloatArray = direction.cgfloatArray(factor)
					if cgfloatArray.count == 6 {
						let controlPoint1 = CGPointMake(cgfloatArray[0], cgfloatArray[1])
						let controlPoint2 = CGPointMake(cgfloatArray[2], cgfloatArray[3])
						lastPoint = CGPointMake(cgfloatArray[4], cgfloatArray[5])
						path.addCurveToPoint(lastPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
					}
				case "c": // Cubic Bezier Curve (relative)
					let cgfloatArray = direction.cgfloatArray(factor)
					if cgfloatArray.count == 6 {
						let controlPoint1 = CGPointMake(cgfloatArray[0] + lastPoint.x, cgfloatArray[1] + lastPoint.y)
						let controlPoint2 = CGPointMake(cgfloatArray[2] + lastPoint.x, cgfloatArray[3] + lastPoint.y)
						lastPoint = CGPointMake(cgfloatArray[4] + lastPoint.x, cgfloatArray[5] + lastPoint.y)
						path.addCurveToPoint(lastPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
					}
				case "S": // Smooth Bezier Curve
					let cgfloatArray = direction.cgfloatArray(factor)
					if cgfloatArray.count == 4 {
						let controlPoint1 = CGPointMake(cgfloatArray[0], cgfloatArray[1])
						lastPoint = CGPointMake(cgfloatArray[2], cgfloatArray[3])
						path.addQuadCurveToPoint(lastPoint, controlPoint: controlPoint1)
					}
				case "s": // Smooth Bezier Curve (relative)
					let cgfloatArray = direction.cgfloatArray(factor)
					if cgfloatArray.count == 4 {
						let controlPoint1 = CGPointMake(cgfloatArray[0] + lastPoint.x, cgfloatArray[1] + lastPoint.y)
						lastPoint = CGPointMake(cgfloatArray[2] + lastPoint.x, cgfloatArray[3] + lastPoint.y)
						path.addQuadCurveToPoint(lastPoint, controlPoint: controlPoint1)
					}
//				case "q": // Quadratic Bezier Curve
//				case "t": // Smooth Quadratic Bezier Curve
//				case "a": // Arc
				case "z": // Closing the Path
					path.closePath()
				default:
					println("missing command \(command) direction \(direction)")
				}
			}
			return path
		}
		
		return nil
	}
	
	// matrix(1 0 0 1 2203.137 2484.1995)
	func matrixValue(name: String, factor:CFloat) -> transformMatrix {
		let valueString = (self[name] as? String)
		if let valueUnwrapped: String = valueString? {
			let start:String.Index = advance(valueUnwrapped.startIndex, 7)
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
	
	func cgfloatValue(factor:CFloat) -> CGFloat {
		let value = self.floatValue() * factor
		return CGFloat(value)
	}
	
	func cgpointValue(factor:CFloat) -> CGPoint {
		let xy = self.componentsSeparatedByString(",")
		if xy.count == 2 {
			let x = xy[0].floatValue() * factor
			let y = xy[1].floatValue() * factor * -1
			let point = CGPointMake(CGFloat(x),CGFloat(y))
			return point
		} else {
			return CGPointMake(0, 0)
		}
	}
	
	func cgfloatArray(factor:CFloat) -> [CGFloat] {
		
		var floatArray: [CGFloat] = []

		let pointSet = NSCharacterSet(charactersInString: ",-")
		let pointScanner = NSScanner(string: self)

		var floatObj:NSString?
		var delimObj:NSString?
		var negative:Bool = false

		while pointScanner.scanUpToCharactersFromSet(pointSet, intoString: &floatObj) {
			var value = CGFloat(floatObj!.floatValue * factor)
		
			if negative {
				value = value * -1
			}
			floatArray.append(value)
			
			pointScanner.scanCharactersFromSet(pointSet, intoString: &delimObj)
			if delimObj != nil {
				negative = delimObj!.isEqualToString("-")
			} else {
				negative = false
			}
		}
		
		return floatArray
	}
	
	func firstCharacter() -> String {
		if self.startIndex != self.endIndex {
			let index = advance(self.startIndex, 1)
			return self.substringToIndex(index)
		}
		return ""
	}
	
	func characterAtIndex(index: Int) -> Character? {
		var cur = 0
		for char in self {
			if cur == index {
				return char
			}
			cur++
		}
		return nil
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
