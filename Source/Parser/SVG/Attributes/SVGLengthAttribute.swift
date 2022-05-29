//
//  SVGWidthAttribute.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import CoreGraphics

class SVGLengthAttribute: SVGDefaultAttribute<CGFloat> {
    
    private let attrName: String
    private let parser: SVGLengthParser

    init(name: String, axis: SVGLengthAxis) {
        self.attrName = name
        self.parser = SVGLengthParser.forAxis(axis)
    }

    override var name: String { attrName }

    override func parse(string: String, context: SVGNodeContext) -> CGFloat? {
        parser.float(string: string, context: context)
    }

    override func defaultValue(context: SVGNodeContext) -> CGFloat { 0 }

}
