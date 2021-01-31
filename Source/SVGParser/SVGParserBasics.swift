//
//  ColorExtension.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 17/07/2020.
//

import SwiftUI

extension SVGHelper {

    static func parseDouble(_ attributes: [String : String], _ key: String, defaultValue: Double = 0) -> Double {
        if let value = Double(attributes[key] ?? "") {
            return value
        }
        return defaultValue
    }

    static func parseCGFloat(_ attributes: [String : String], _ key: String, defaultValue: CGFloat = 0) -> CGFloat {
        if let value = Double(attributes[key] ?? "") {
            return CGFloat(value)
        }
        return defaultValue
    }

    static func parseOptCGFloat(_ attributes: [String : String], _ key: String) -> CGFloat? {
        if let value = Double(attributes[key] ?? "") {
            return CGFloat(value)
        }
        return .none
    }

    static func parsePointsArray(_ string: String) -> [CGPoint] {
        var resultPoints: [CGPoint] = []
        let numbersString = string.replacingOccurrences(of: ",", with: " ")
        let numbers = numbersString.split(separator: " ")

        var i = 0
        while i < numbers.count - 1 {
            let x = Double(numbers[i]) ?? 0
            let y = Double(numbers[i+1]) ?? 0
            resultPoints.append(CGPoint(x: x, y: y))
            i += 2
        }
        return resultPoints
    }

    static func parseOpacity(_ attributes: [String : String], _ key: String) -> Double {
        let opacity = parseDouble(attributes, key, defaultValue: 1)
        return min(max(opacity, 0), 1)
    }

    static func parseFill(_ style: [String : String]) -> SVGPaint? {
        guard let colorString = style["fill"] else {
            return .color(Color.black.opacity(parseOpacity(style, "fill-opacity")))
        }
        if let color = parseColor(colorString) {
            return .color(color.opacity(parseOpacity(style, "fill-opacity")))
        }
        return .none
    }

    static func parseColor(_ string: String) -> Color? {
        let normalized = string.replacingOccurrences(of: " ", with: "")
        if normalized == "none" || normalized == "transparent" {
            return .none
        } else if let defaultColor = Color.by(name: normalized) {
            return defaultColor
        } else if normalized.hasPrefix("rgb") {
            return parseRGBNotation(colorString: normalized)
        } else {
            return createColorFromHex(normalized)
        }
    }

    static func createColorFromHex(_ hexString: String) -> Color {
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            cleanedHexString = hexString.replacingOccurrences(of: "#", with: "")
        }
        if cleanedHexString.count == 3 {
            let x = Array(cleanedHexString)
            cleanedHexString = "\(x[0])\(x[0])\(x[1])\(x[1])\(x[2])\(x[2])"
        }
        return Color(hex: cleanedHexString)
    }

    static func parseRGBNotation(colorString: String) -> Color {
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
        let div = inPercentage ? 100.0 : 255.0
        return Color(red: red / div, green: green / div, blue: blue / div)
    }
}
