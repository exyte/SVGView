//
//  SVGStructure.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import CoreGraphics

class SVGViewportParser: SVGGroupParser {

    override func doParse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        let attributes = context.properties
        let widthAttributeNil = attributes["width"] == nil
        let heightAttributeNil = attributes["height"] == nil
        let viewBoxAttributeNil = attributes["viewBox"] == nil

        if widthAttributeNil && heightAttributeNil && viewBoxAttributeNil {
            return .none
        }

        let w = SVGHelper.parseDimension(attributes, "width") ?? SVGLength(percent: 100)
        let h = SVGHelper.parseDimension(attributes, "height") ?? SVGLength(percent: 100)

        var viewBox: CGRect?
        if let viewBoxString = attributes["viewBox"] {
            let nums = viewBoxString.components(separatedBy: .whitespaces).map { Double($0) }
            if nums.count == 4, let x = nums[0], let y = nums[1], let w = nums[2], let h = nums[3] {
                viewBox = CGRect(x: x, y: y, width: w, height: h)
            }
        }

        let par = SVGHelper.parsePreserveAspectRation(string: attributes["preserveAspectRatio"])
        return SVGViewport(width: w, height: h, viewBox: viewBox, preserveAspectRatio: par, contents: parseContents(context: context, delegate: delegate))
    }

}

class SVGGroupParser: SVGBaseElementParser {

    override func doParse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        return SVGGroup(contents: parseContents(context: context, delegate: delegate))
    }

    func parseContents(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> [SVGNode] {
        return context.element.contents
            .compactMap { $0 as? XMLElement }
            .compactMap { delegate($0) }
    }

}

class SVGUseParser: SVGBaseElementParser {

    override func doParse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        guard let useId = context.properties["xlink:href"]?.replacingOccurrences(of: "#", with: ""),
              let def = context.index.element(by: useId),
              let useNode = delegate(def) else {
            return nil
        }
        useNode.transform = CGAffineTransform(
            translationX: SVGHelper.parseCGFloat(context.properties, "x"),
            y: SVGHelper.parseCGFloat(context.properties, "y"))
        return useNode
    }
}
