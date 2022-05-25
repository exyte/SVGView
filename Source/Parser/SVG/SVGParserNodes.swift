//
//  SVGParserNodes.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 28/07/2020.
//

import SwiftUI

public class SVGHelper: NSObject {

    static func parseNode(xml: XMLElement, index: SVGIndex, attributes: [String: String], style: [String: String]) -> SVGNode? {

        let name = xml.name
        switch name {
        case "title", "desc", "mask", "clip", "filter",
             "linearGradient", "radialGradient", "fill":
            break
        case "image":
            return parseImage(attributes, style: style)
        case "text":
            return parseText(xml: xml, index: index, attributes: attributes, style: style)
        default:
            return parseShape(name: name,  index: index, attributes: attributes, style: style)
        }

        return .none
    }

    static func parseText(xml: XMLElement, index: SVGIndex, attributes: [String: String], style: [String: String]) -> SVGText? {

        let fontName = style["font-family"] ?? "Serif"
        let fontSize = style["font-size"]?.cgFloatValue ?? 12
        let fontWeight = style["font-weight"] ?? "normal"
        let font = SVGFont(name: fontName, size: fontSize, weight: fontWeight)
        let textAnchor = parseTextAnchor(style["text-anchor"])

        let x = parseCGFloat(attributes, "x")
        let y = parseCGFloat(attributes, "y")
        let transform = CGAffineTransform(translationX: x, y: y)

        if let textNode = xml.contents.first as? XMLText {
            let trimmed = textNode.text.trimmingCharacters(in: .whitespacesAndNewlines).processingWhitespaces()
            return SVGText(text: trimmed, font: font, fill: parseFill(style, index), stroke: parseStroke(style, index: index), textAnchor: textAnchor, transform: transform)
        }
        return .none
    }

    static func parseShape(name: String, index: SVGIndex, attributes: [String: String], style: [String: String]) -> SVGShape? {

        if let locus = parseLocus(name: name, attributes: attributes, style: style) {
            locus.fill = parseFill(style, index)
            locus.stroke = parseStroke(style, index: index)
            return locus
        }
        return .none
    }

    static var whitespaceRegex = try! NSRegularExpression(pattern: "\\s+", options: NSRegularExpression.Options.caseInsensitive)
}

extension String {

    fileprivate func processingWhitespaces() -> String {
        let range = NSMakeRange(0, self.count)
        let modString = SVGHelper.whitespaceRegex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: " ")
        return modString
    }
}
