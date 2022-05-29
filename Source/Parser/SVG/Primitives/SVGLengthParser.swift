//
//  SVGLengthParser.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import Foundation
import CoreGraphics

enum SVGLengthAxis {

    case x
    case y
    case all

    func value(percent: Double, width: Double, height: Double) -> Double {
        switch self {
        case .x:
            return percent / 100 * width
        case .y:
            return percent / 100 * height
        case .all:
            return percent / 100 * sqrt(width * width + height * height) / sqrt(2)
        }
    }
}

class SVGLengthParser {

    static let `default` = SVGLengthParser(axis: .all)
    static let xAxis = SVGLengthParser(axis: .x)
    static let yAxis = SVGLengthParser(axis: .y)
    static let fontSize = SVGLengthParser(axis: .all, isFontRelative: false)

    public static func forAxis(_ axis: SVGLengthAxis) -> SVGLengthParser {
        switch axis {
            case .x: return xAxis
            case .y: return yAxis
            default: return Self.default
        }
    }

    let axis: SVGLengthAxis
    let isFontRelative: Bool

    private init(axis: SVGLengthAxis, isFontRelative: Bool = true) {
        self.axis = axis
        self.isFontRelative = isFontRelative
    }

    func float(string: String, context: SVGContext) -> CGFloat? {
        if let doubleValue = double(string: string, context: context) {
            return CGFloat(doubleValue)
        }
        return nil
    }

    func double(string: String, context: SVGContext) -> Double? {
        if string == "none" {
            return 0
        }

        let scanner = Scanner(string: string)
        guard let value = scanner.scanDouble() else { return nil }
        let unit = scanner.scanCharacters(from: .unit)?.lowercased()

        switch unit {
        case nil, "px":
            return value
        case "in":
            return value * context.screen.ppi
        case "cm":
            return value * context.screen.ppi / 2.54
        case "pc":
            return value * context.screen.ppi / 6
        case "mm":
            return value * context.screen.ppi / 25.4
        case "pt":
            return value * context.screen.ppi / 72
        case "%":
            return axis.value(percent: value, width: context.screen.width, height: context.screen.height)
        default:
            if isFontRelative {
                if unit == "em" {
                    return value * context.fontSize
                }
                if unit == "ex" {
                    // TODO: actually x-height is not equals to font-size / 2
                    return value * context.fontSize / 2
                }
            }
            context.log(message: "SVG parsing error. Unit \"\(unit ?? "")\" is not supported")
            return value
        }
    }

}

extension CharacterSet {

    static let unit = CharacterSet(charactersIn: "a"..."z")
        .union(CharacterSet(charactersIn: "A"..."Z"))
        .union(CharacterSet(charactersIn: "%"))

}
