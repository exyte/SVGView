//
//  SVGView.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/07/2020.
//

import SwiftUI

public struct SVGParser {

    static var fileURL: URL?

    static public func parse(fileURL: URL) -> SVGNode? {
        let xml = DOMParser.parse(fileURL: fileURL)
        return parse(xml: xml, fileURL: fileURL)
    }

    static public func parse(data: Data, fileURL: URL? = nil) -> SVGNode? {
        let xml = DOMParser.parse(data: data)
        return parse(xml: xml, fileURL: fileURL)
    }

    static public func parse(string: String, fileURL: URL? = nil) -> SVGNode? {
        let xml = DOMParser.parse(string: string)
        return parse(xml: xml, fileURL: fileURL)
    }

    static public func parse(stream: InputStream, fileURL: URL? = nil) -> SVGNode? {
        let xml = DOMParser.parse(stream: stream)
        return parse(xml: xml, fileURL: fileURL)
    }

    static public func parse(xml: XMLElement?, fileURL: URL? = nil) -> SVGNode? {
        guard let xml = xml else {
            return nil
        }
        self.fileURL = fileURL
        let index = SVGIndex()
        index.fill(from: xml)
        return parseInternal(xml: xml, index: index)
    }

    static func parseInternal(xml: XMLElement, index: SVGIndex, accumulatedUseIdentifiers: [String] = [], ignoreDefs: Bool = true) -> SVGNode? {
        if ignoreDefs, SVGConstants.defTags.contains(xml.name) {
            return nil
        }

        let styleDict = getStyleAttributes(xml: xml, index: index)
        let nonStyleDict = xml.attributes.filter { !SVGConstants.availableStyleAttributes.contains($0.key) }

        let collector = SVGAttributesCollector.shared
        collector.styleStack.pushStyle(styleDict)

        var result: SVGNode?
        let contents = xml.contents.compactMap { $0 as? XMLElement }
        if isGroup(xml: xml) { // group
            var nodes = [SVGNode]()
            for child in contents {
                if let node = parseInternal(xml: child, index: index, accumulatedUseIdentifiers: accumulatedUseIdentifiers, ignoreDefs: ignoreDefs) {
                    nodes.append(node)
                }
            }
            if let svg = parseViewport(nonStyleDict, nodes) {
                result = svg
            } else {
                result = SVGGroup(contents: nodes)
            }
        }
        else {
            let collectedStyle = collector.styleStack.currentStyle()
            if xml.name == "use", // def
               let useId = nonStyleDict["xlink:href"]?.replacingOccurrences(of: "#", with: "") {
                if accumulatedUseIdentifiers.contains(useId) {
                    return nil // <use> recursion detected
                }
                let ids = accumulatedUseIdentifiers + [useId]
                if let def = index.element(by: useId),
                   let useNode = parseInternal(xml: def, index: index, accumulatedUseIdentifiers: ids, ignoreDefs: ignoreDefs) {

                    useNode.transform = CGAffineTransform(
                        translationX: SVGHelper.parseCGFloat(nonStyleDict, "x"),
                        y: SVGHelper.parseCGFloat(nonStyleDict, "y"))
                    result = useNode
                }
            }
            else { // simple node
                result = SVGHelper.parseNode(xml: xml, index: index, attributes: nonStyleDict, style: collectedStyle)
            }
        }

        let transform = SVGHelper.parseTransform(nonStyleDict["transform"] ?? "")
        result?.transform = result?.transform.concatenating(transform) ?? CGAffineTransform.identity

        result?.opacity = SVGHelper.parseOpacity(styleDict, "opacity")

        if let clipId = SVGHelper.parseUse(styleDict["clip-path"]),
           let clipNode = index.element(by: clipId),
           let clip = parseInternal(xml: clipNode, index: index, accumulatedUseIdentifiers: accumulatedUseIdentifiers, ignoreDefs: false) {
            result?.clip = SVGUserSpaceNode(node: clip, userSpace: parse(userSpace: clipNode.attributes["clipPathUnits"]))
        }

        result?.id = SVGHelper.parseId(nonStyleDict)

        collector.styleStack.popStyle()

        return result
    }

    static func getStyleAttributes(xml: XMLElement, index: SVGIndex) -> [String: String] {
        var styleDict = xml.attributes.filter { SVGConstants.availableStyleAttributes.contains($0.key) }
            .filter { $0.value != "inherit" }

        for (att, val) in index.cssStyle(for: xml) {
            if styleDict.index(forKey: att) == nil {
                styleDict.updateValue(val, forKey: att)
            }
        }

        if let cssStyle = xml.attributes["style"] {
            let styleParts = cssStyle.replacingOccurrences(of: " ", with: "").components(separatedBy: ";")
            styleParts.forEach { styleAttribute in
                let currentStyle = styleAttribute.components(separatedBy: ":")
                if currentStyle.count == 2 {
                    styleDict.updateValue(currentStyle[1], forKey: currentStyle[0])
                }
            }
        }

        return styleDict
    }

    static func isGroup(xml: XMLElement) -> Bool {
        switch xml.name {
        case "g", "svg":
            return true
        default:
            return false
        }
    }

    static func parseViewport(_ attributes: [String: String], _ nodes: [SVGNode]) -> SVGViewport? {
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
        return SVGViewport(width: w, height: h, viewBox: viewBox, preserveAspectRatio: par, contents: nodes)
    }

    static func parse(userSpace: String?) -> SVGUserSpaceNode.UserSpace {
        if let value = userSpace, let result = SVGUserSpaceNode.UserSpace(rawValue: value) {
            return result
        }
        return SVGUserSpaceNode.UserSpace.objectBoundingBox
    }

}

class SVGAttributesCollector {

    let styleStack = StyleStack()

    static let shared = SVGAttributesCollector()
}
