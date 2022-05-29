//
//  SVGAttribute.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import Foundation

class SVGAttribute<Value> {

    static var fontSize: SVGFontSizeAttribute { SVGAttributes.fontSize }
    static var x: SVGLengthAttribute { SVGAttributes.x }
    static var y: SVGLengthAttribute { SVGAttributes.y }
    static var width: SVGLengthAttribute { SVGAttributes.width }
    static var height: SVGLengthAttribute { SVGAttributes.height }
    static var r: SVGLengthAttribute { SVGAttributes.r }
    static var rx: SVGLengthAttribute { SVGAttributes.rx }
    static var ry: SVGLengthAttribute { SVGAttributes.ry }
    static var cx: SVGLengthAttribute { SVGAttributes.cx }
    static var cy: SVGLengthAttribute { SVGAttributes.cy }
    static var x1: SVGLengthAttribute { SVGAttributes.x1 }
    static var x2: SVGLengthAttribute { SVGAttributes.x2 }
    static var y1: SVGLengthAttribute { SVGAttributes.y1 }
    static var y2: SVGLengthAttribute { SVGAttributes.y2 }

    var name: String { "" }
    var isInherited: Bool { false }

    func parse(string: String, context: SVGNodeContext) -> Value? {
        fatalError("SVGAttribute.parse(string:context:) should be overwritten by inheritor")
    }

}

class SVGDefaultAttribute<Value>: SVGAttribute<Value> {

    func defaultValue(context: SVGNodeContext) -> Value {
        fatalError("SVGAttribute.defaultValue(context:) should be overwritten by inheritor")
    }

}

class SVGAttributes {

    static let fontSize = SVGFontSizeAttribute()
    static let x = SVGLengthAttribute(name: "x", axis: .x)
    static let y = SVGLengthAttribute(name: "y", axis: .y)
    static let width = SVGLengthAttribute(name: "width", axis: .x)
    static let height = SVGLengthAttribute(name: "height", axis: .y)
    static let r = SVGLengthAttribute(name: "r", axis: .all)
    static let rx = SVGLengthAttribute(name: "rx", axis: .x)
    static let ry = SVGLengthAttribute(name: "ry", axis: .y)
    static let cx = SVGLengthAttribute(name: "cx", axis: .x)
    static let cy = SVGLengthAttribute(name: "cy", axis: .y)
    static let x1 = SVGLengthAttribute(name: "x1", axis: .x)
    static let x2 = SVGLengthAttribute(name: "x2", axis: .x)
    static let y1 = SVGLengthAttribute(name: "y1", axis: .y)
    static let y2 = SVGLengthAttribute(name: "y2", axis: .y)

}
