//
//  SVGParser.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/07/2020.
//

import SwiftUI

extension SVGHelper {

    static func parseLocus(name: String, attributes: [String: String], style: [String: String]) -> SVGShape? {
        switch name {
        case "circle":
            return parseCircle(attributes, style: style)
        case "ellipse":
            return parseEllipse(attributes, style: style)
        case "line":
            return parseLine(attributes, style: style)
        case "path":
            return parsePath(attributes, style: style)
        case "polygon":
            return parsePolygon(attributes, style: style)
        case "polyline":
            return parsePolyline(attributes, style: style)
        case "rect":
            return parseRect(attributes, style: style)
        default:
            print("SVG parsing error. Shape \(name) not supported")
            return .none
        }
    }

    static func parseCircle(_ attributes: [String: String], style: [String: String]) -> SVGCircle {
        let radius = parseCGFloat(attributes, "r")
        let x = parseCGFloat(attributes, "cx")
        let y = parseCGFloat(attributes, "cy")
        return SVGCircle(cx: x, cy: y, r: radius)
    }

    static func parseEllipse(_ attributes: [String: String], style: [String: String]) -> SVGEllipse {
        let x = parseCGFloat(attributes, "cx")
        let y = parseCGFloat(attributes, "cy")
        let rx = parseCGFloat(attributes, "rx")
        let ry = parseCGFloat(attributes, "ry")
        return SVGEllipse(cx: x, cy: y, rx: rx, ry: ry)
    }

    static func parseLine(_ attributes: [String: String], style: [String: String]) -> SVGLine {
        let x1 = parseCGFloat(attributes, "x1")
        let y1 = parseCGFloat(attributes, "y1")
        let x2 = parseCGFloat(attributes, "x2")
        let y2 = parseCGFloat(attributes, "y2")
        return SVGLine(x1, y1, x2, y2)
    }

    static func parsePath(_ attributes: [String: String], style: [String: String]) -> SVGPath {
        let segments = PathReader(input: attributes["d"] ?? "").read()
        return SVGPath(segments: segments, fillRule: getFillRule(style))
    }

    static func getFillRule(_ style: [String: String]) -> CGPathFillRule {
        return style["fill-rule"] == "evenodd" ? .evenOdd : .winding
    }

    static func parsePolygon(_ attributes: [String: String], style: [String: String]) -> SVGPolygon {
        let points = SVGHelper.parsePointsArray(attributes["points"] ?? "")
        return SVGPolygon(points)
    }

    static func parsePolyline(_ attributes: [String: String], style: [String: String]) -> SVGPolyline {
        let points = SVGHelper.parsePointsArray(attributes["points"] ?? "")
        return SVGPolyline(points)
    }

    static func parseRect(_ attributes: [String: String], style: [String: String]) -> SVGShape {
        let x = parseCGFloat(attributes, "x")
        let y = parseCGFloat(attributes, "y")
        let width = parseCGFloat(attributes, "width")
        let height = parseCGFloat(attributes, "height")
        let rxOpt = parseOptCGFloat(attributes, "rx")
        let ryOpt = parseOptCGFloat(attributes, "ry")
        let rx = rxOpt ?? ryOpt ?? 0
        let ry = ryOpt ?? rxOpt ?? 0
        return SVGRect(x: x, y: y, width: width, height: height, rx: rx, ry: ry)
    }

}
