//
//  SVGParserNodes.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 28/07/2020.
//

import SwiftUI

public class SVGHelper: NSObject {

    static func parseNode(xml: XMLElement, attributes: [String : String], style: [String : String]) -> SVGNode? {

        let name = xml.name
        switch name {
        case "title", "desc", "mask", "clip", "filter",
             "linearGradient", "radialGradient", "fill":
            break
        case "image":
            return parseImage(attributes, style: style)
        case "text":
            return parseText(xml: xml, attributes: attributes, style: style)
        default:
            return parseShape(name: name, attributes: attributes, style: style)
        }

        return .none
    }

    static func parseImage(_ attributes: [String : String], style: [String : String]) -> SVGNode? {
        print("Image not supported")
        return .none
    }

    static func parseText(xml: XMLElement, attributes: [String : String], style: [String : String]) -> SVGText? {

        let fontName = style["font-family"] ?? "Serif"
        let fontSize = style["font-size"]?.cgFloatValue ?? 12
        let fontWeight = style["font-weight"] ?? "normal"
        let font = SVGFont(name: fontName, size: fontSize, weight: fontWeight)
        let textAnchor = parseTextAnchor(style["text-anchor"])

        let x = parseCGFloat(attributes, "x")
        let y = parseCGFloat(attributes, "y")
        let transform = CGAffineTransform(translationX: x, y: y)

        if let textNode = xml.contents.first as? XMLText {
            return SVGText(text: textNode.text, font: font, fill: parseFill(style), stroke: parseStroke(style), textAnchor: textAnchor, transform: transform)
        }
        return .none
    }

    static func parseShape(name: String, attributes: [String : String], style: [String : String]) -> SVGShape? {

        if let locus = parseLocus(name: name, attributes: attributes, style: style) {
            locus.fill = parseFill(style)
            locus.stroke = parseStroke(style)
            return locus
        }
        return .none
    }
}
