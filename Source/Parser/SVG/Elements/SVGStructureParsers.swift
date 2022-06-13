//
//  SVGStructure.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import Foundation
import CoreGraphics

class SVGViewportParser: SVGGroupParser {

    override func doParse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        let attributes = context.properties

        let w = Self.parseDimension(attributes, "width") ?? SVGLength(percent: 100)
        let h = Self.parseDimension(attributes, "height") ?? SVGLength(percent: 100)
        let viewBox = Self.parseViewBox(attributes, context: context)
        let par = Self.parsePreserveAspectRation(string: attributes["preserveAspectRatio"], context: context)
        return SVGViewport(width: w, height: h, viewBox: viewBox, preserveAspectRatio: par, contents: parseContents(context: context, delegate: delegate))
    }

    static func parseDimension(_ attributes: [String: String], _ key: String) -> SVGLength? {
        guard let string = attributes[key] else {
            return .none
        }
        if string.hasSuffix("%"), let value = Double(string.dropLast()) {
            return SVGLength(percent: CGFloat(value))
        }
        if let value = Double(string) {
            return SVGLength(pixels: CGFloat(value))
        }
        return .none
    }

    static func parseViewBox(_ attributes: [String: String], context: SVGContext) -> CGRect? {
        // TODO: temporary solution, all attributes should be case insensitive
        if let string = attributes[ignoreCase: "viewBox"] {
            let nums = string.components(separatedBy: .whitespaces)
            if nums.count == 4,
               let x = SVGLengthParser.xAxis.double(string: nums[0], context: context),
               let y = SVGLengthParser.yAxis.double(string: nums[1], context: context),
               let width = SVGLengthParser.xAxis.double(string: nums[2], context: context),
               let height = SVGLengthParser.yAxis.double(string: nums[3], context: context) {
                return CGRect(x: x, y: y, width: width, height: height)
            }
        }
        return nil
    }

    static func parsePreserveAspectRation(string: String?, context: SVGContext) -> SVGPreserveAspectRatio {
        if let contentModeString = string {
            let strings = contentModeString.components(separatedBy: CharacterSet(charactersIn: " "))
            if strings.count == 1 { // none
                return SVGPreserveAspectRatio(scaling: parseScaling(strings[0]))
            }
            guard strings.count == 2 else {
                context.log(message: "Invalid content mode \(contentModeString)")
                return SVGPreserveAspectRatio()
            }

            let alignString = strings[0]
            var xAlign = alignString.prefix(4).lowercased()
            xAlign.remove(at: xAlign.startIndex)
            let xAligningMode = parseAlign(xAlign)

            var yAlign = alignString.suffix(4).lowercased()
            yAlign.remove(at: yAlign.startIndex)
            let yAligningMode = parseAlign(yAlign)

            let scalingMode = parseScaling(strings[1])
            return SVGPreserveAspectRatio(scaling: scalingMode, xAlign: xAligningMode, yAlign: yAligningMode)
        }
        return SVGPreserveAspectRatio()
    }

    static func parseAlign(_ string: String) -> SVGPreserveAspectRatio.Align {
        switch string {
            case "min": return .min
            case "max": return .max
            default: return .mid
        }
    }

    static func parseScaling(_ string: String) -> SVGPreserveAspectRatio.Scaling {
        switch string {
            case "meet": return .meet
            case "slice": return .slice
            default: return .none
        }
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
