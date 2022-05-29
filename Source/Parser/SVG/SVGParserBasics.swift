//
//  ColorExtension.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 17/07/2020.
//

import SwiftUI

extension SVGHelper {

    static func parseDouble(_ attributes: [String: String], _ key: String, defaultValue: Double = 0) -> Double {
        if let value = attributes[key], let result = doubleFromString(value) {
            return result
        }
        return defaultValue
    }

    static func parseCGFloat(_ attributes: [String: String], _ key: String, defaultValue: CGFloat = 0) -> CGFloat {
        if let value = attributes[key], let result = doubleFromString(value) {
            return CGFloat(result)
        }
        return defaultValue
    }

    static func doubleFromString(_ string: String) -> Double? {
        if string == "none" {
            return 0
        }

        let scanner = Scanner(string: string)
        let value = scanner.scanDouble()
        let unit = scanner.scanCharacters(from: .unitCharacters)

        switch unit {
        case nil, "px":
            return value
        default:
            print("SVG parsing error. Unit \"\(unit ?? "")\" is not supported")
            return value
        }
    }

    static func parsePointsArray(_ string: String) -> [CGPoint] {
        var numbers: [Double] = []

        let scanner = Scanner(string: string)
        while !scanner.isAtEnd {
            if let value = scanner.scanDouble() {
                numbers.append(value)
            }
            _ = scanner.scanCharacters(from: [","])
        }

        var points: [CGPoint] = []
        var i = 0
        while i < numbers.count - 1 {
            points.append(CGPoint(x: numbers[i], y: numbers[i + 1]))
            i += 2
        }

        return points
    }

    static func parseOpacity(_ attributes: [String: String], _ key: String) -> Double {
        let opacity = parseDouble(attributes, key, defaultValue: 1)
        return min(max(opacity, 0), 1)
    }

    static func parseFill(_ style: [String: String], _ index: SVGIndex) -> SVGPaint? {
        guard let colorString = style["fill"] else {
            return SVGColor.black.opacity(parseOpacity(style, "fill-opacity"))
        }
        return parseFillInternal(colorString, style, index)
    }

    static func parseStrokeFill(_ style: [String: String], _ index: SVGIndex) -> SVGPaint? {
        guard let colorString = style["stroke"] else {
            return .none
        }
        return parseFillInternal(colorString, style, index)
    }

    static func parseFillInternal(_ colorString: String, _ style: [String: String], _ index: SVGIndex) -> SVGPaint? {
        if let colorId = SVGHelper.parseIdFromUrl(colorString) {
            if let paint = index.paint(by: colorId) {
                return paint
            }
        }
        if let color = parseColor(colorString, style) {
            return color.opacity(parseOpacity(style, "fill-opacity"))
        }
        
        return .none
    }

    static func parseColor(_ string: String, _ style: [String: String]) -> SVGColor? {
        let normalized = string.replacingOccurrences(of: " ", with: "")
        if normalized == "none" || normalized == "transparent" {
            return .none
        } else if normalized == "currentColor", let currentColor = style["color"] {
            return parseColor(currentColor, style)
        } else if let defaultColor = SVGColor.by(name: normalized) {
            return defaultColor
        } else if normalized.hasPrefix("rgb") {
            return parseRGBNotation(colorString: normalized)
        } else {
            return createColorFromHex(normalized)
        }
    }

    static func createColorFromHex(_ hexString: String) -> SVGColor {
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            cleanedHexString = hexString.replacingOccurrences(of: "#", with: "")
        }
        if cleanedHexString.count == 3 {
            let x = Array(cleanedHexString)
            cleanedHexString = "\(x[0])\(x[0])\(x[1])\(x[1])\(x[2])\(x[2])"
        }
        return SVGColor(hex: cleanedHexString)
    }

    static func parseRGBNotation(colorString: String) -> SVGColor {
        let from = colorString.index(colorString.startIndex, offsetBy: 4)
        let inPercentage = colorString.contains("%")
        let sp = String(colorString.suffix(from: from))
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "")
        let x = sp.components(separatedBy: ",")
        var red = 0.0
        var green = 0.0
        var blue = 0.0
        if x.count == 3 {
            if let r = Double(x[0]), let g = Double(x[1]), let b = Double(x[2]) {
                blue = b
                green = g
                red = r
            }
        }
        if inPercentage {
            red *= 2.55
            green *= 2.55
            blue *= 2.55
        }
        return SVGColor(r: Int(round(red)), g: Int(round(green)), b: Int(round(blue)))
    }

    static private func parseIdFromUrl(_ urlString: String) -> String? {
        if urlString.hasPrefix("url") {
            return urlString.substringWithOffset(fromStart: 5, fromEnd: 1)
        }
        return .none
    }

}

fileprivate extension String {
    func substringWithOffset(fromStart: Int, fromEnd: Int) -> String {
        let start = index(startIndex, offsetBy: fromStart)
        let end = index(endIndex, offsetBy: -fromEnd)
        return String(self[start..<end])
    }
}

extension CharacterSet {
    /// Latin alphabet characters.
    static let latinAlphabet = CharacterSet(charactersIn: "a"..."z")
        .union(CharacterSet(charactersIn: "A"..."Z"))

    static let unitCharacters = CharacterSet.latinAlphabet

    static let transformationAttributeCharacters = CharacterSet.latinAlphabet
}
