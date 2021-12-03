//
//  SVGParserViewBox.swift
//  Pods
//
//  Created by Alisa Mylnikova on 13/10/2020.
//

import SwiftUI

extension SVGHelper {

    static func parsePreserveAspectRation(string: String?) -> SVGPreserveAspectRatio {
        if let contentModeString = string {
            let strings = contentModeString.components(separatedBy: CharacterSet(charactersIn: " "))
            if strings.count == 1 { // none
                return SVGPreserveAspectRatio(scaling: parseScaling(strings[0]))
            }
            guard strings.count == 2 else {
                // TODO need some logging there
                fatalError("Invalid content mode")
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

    static func parseAlign(_ string: String) -> SVGPreserveAspectRatio.Align {
        if string == "min" {
            return .min
        }
        if string == "mid" {
            return .mid
        }
        return .max
    }

    static func parseScaling(_ string: String) -> SVGPreserveAspectRatio.Scaling {
        if string == "meet" {
            return .meet
        }
        if string == "slice" {
            return .slice
        }
        return .none
    }
}
