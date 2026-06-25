//
//  SVGParserPrimitives.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/07/2020.
//

#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
#endif

public class SVGHelper: NSObject {

    static func parseUse(_ use: String?) -> String? {
        guard let use = use else {
            return .none
        }
        return use.replacingOccurrences(of: "url(#", with: "")
            .replacingOccurrences(of: ")", with: "")
    }

    static func parseId(_ dict: [String: String]) -> String? {
        return dict["id"] ?? dict["xml:id"]
    }

    static func parseMarkerInAttribute(_ dict: [String: String], key: String) -> String? {
        guard let markerId = dict[key] else {
            return .none
        }
        return markerId.replacingOccurrences(of: "url(#", with: "")
            .replacingOccurrences(of: ")", with: "")
    }

    static func parseStroke(_ style: [String: String], index: SVGIndex) -> SVGStroke? {
        guard let fill = SVGHelper.parseStrokeFill(style, index) else {
            return .none
        }

        return SVGStroke(
            fill: fill.opacity(SVGHelper.parseOpacity(style, "stroke-opacity", alternativeKeys: ["opacity"])),
            width: parseCGFloat(style, "stroke-width", defaultValue: 1),
            cap: getStrokeCap(style),
            join: getStrokeJoin(style),
            miterLimit: parseCGFloat(style, "stroke-miterlimit", defaultValue: 4),
            dashes: getStrokeDashes(style),
            offset: parseCGFloat(style, "stroke-dashoffset"))
    }

    static func getStrokeDashes(_ style: [String: String]) -> [CGFloat] {
        var dashes = [CGFloat]()
        if let strokeDashes = style["stroke-dasharray"] {
            let separatedValues = strokeDashes.components(separatedBy: CharacterSet(charactersIn: " ,"))
            separatedValues.forEach { value in
                if let doubleValue = doubleFromString(value) {
                    dashes.append(CGFloat(doubleValue))
                }
            }
        }
        return dashes
    }

    static func getStrokeCap(_ style: [String: String]) -> CGLineCap {
        if let strokeCap = style["stroke-linecap"] {
            switch strokeCap {
            case "round":
                return .round
            case "square":
                return .square
            default:
                break
            }
        }
        return .butt
    }

    static func getStrokeJoin(_ style: [String: String]) -> CGLineJoin {
        if let strokeJoin = style["stroke-linejoin"] {
            switch strokeJoin {
            case "round":
                return .round
            case "bevel":
                return .bevel
            default:
                break
            }
        }
        return .miter
    }

    static func parseTransform(_ attributes: String, transform: CGAffineTransform = CGAffineTransform.identity) -> CGAffineTransform {
        guard let matcher = SVGParserRegexHelper.getTransformAttributeMatcher() else {
            return transform
        }

        let attributes = attributes.replacingOccurrences(of: "\n", with: "")
        var finalTransform = transform
        let fullRange = NSRange(location: 0, length: attributes.count)

        guard let matchedAttribute = matcher.firstMatch(in: attributes, options: .reportCompletion, range: fullRange) else {
            return finalTransform
        }
        let attributeName = (attributes as NSString).substring(with: matchedAttribute.range(at: 1))
        let values = parseTransformValues((attributes as NSString).substring(with: matchedAttribute.range(at: 2)))
        if values.isEmpty {
            return finalTransform
        }
        switch attributeName {
        case "translate":
            if let x = values[0].cgFloatValue {
                var y: CGFloat = 0
                if values.indices.contains(1) {
                    y = values[1].cgFloatValue ?? 0
                }
                finalTransform = finalTransform.translatedBy(x: x, y: y)
            }
        case "scale":
            if let x = values[0].cgFloatValue {
                var y = x
                if values.indices.contains(1) {
                    y = values[1].cgFloatValue ?? x
                }
                finalTransform = finalTransform.scaledBy(x: x, y: y)
            }
        case "rotate":
            if let angle = values[0].cgFloatValue {
                if values.count == 1 {
                    finalTransform = finalTransform.rotated(by: angle.degreesToRadians)
                } else if values.count == 3 {
                    if let x = values[1].cgFloatValue, let y = values[2].cgFloatValue {
                        finalTransform = finalTransform.translatedBy(x: x, y: y).rotated(by: angle.degreesToRadians).translatedBy(x: -x, y: -y)
                    }
                }
            }
        case "skewX":
            if let x = values[0].cgFloatValue {
                let v = tan((x * .pi) / 180.0)
                finalTransform = finalTransform.shear(shx: v, shy: 0)
            }
        case "skewY":
            if let y = values[0].cgFloatValue {
                let y = tan((y * .pi) / 180.0)
                finalTransform = finalTransform.shear(shx: 0, shy: y)
            }
        case "matrix":
            if values.count != 6 {
                return finalTransform
            }
            if let a = values[0].cgFloatValue, let b = values[1].cgFloatValue,
               let c = values[2].cgFloatValue, let d = values[3].cgFloatValue,
               let tx = values[4].cgFloatValue, let ty = values[5].cgFloatValue {

                let transformMatrix = CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
                finalTransform = finalTransform.concatenating(transformMatrix)
            }
        default:
            break
        }
        let rangeToRemove = NSRange(location: 0,
                                    length: matchedAttribute.range.location + matchedAttribute.range.length)
        let newAttributeString = (attributes as NSString).replacingCharacters(in: rangeToRemove, with: "")
        return parseTransform(newAttributeString, transform: finalTransform)
    }

    static func parseTransformValues(_ values: String, collectedValues: [String] = []) -> [String] {
        guard let matcher = SVGParserRegexHelper.getTransformMatcher() else {
            return collectedValues
        }
        var updatedValues: [String] = collectedValues
        let fullRange = NSRange(location: 0, length: values.count)
        if let matchedValue = matcher.firstMatch(in: values, options: .reportCompletion, range: fullRange) {
            let value = (values as NSString).substring(with: matchedValue.range)
            updatedValues.append(value)
            let rangeToRemove = NSRange(location: 0, length: matchedValue.range.location + matchedValue.range.length)
            let newValues = (values as NSString).replacingCharacters(in: rangeToRemove, with: "")
            return parseTransformValues(newValues, collectedValues: updatedValues)
        }
        return updatedValues
    }

    static func transformForNodeInRespectiveCoords(respective: SVGNode, absolute: SVGNode) -> CGAffineTransform {
        let absoluteBounds = absolute.bounds()
        let respectiveBounds = respective.bounds()
        let finalSize = CGSize(width: absoluteBounds.width * respectiveBounds.width,
                               height: absoluteBounds.height * respectiveBounds.height)
        let scale = SVGPreserveAspectRatio(scaling: .none).layout(size: respectiveBounds.size, into: finalSize)
        let move = CGAffineTransform(translationX: absoluteBounds.minX, y: absoluteBounds.minY)
        return scale.concatenating(move)
    }

    static func parseViewPort(_ attributes: [String: String], context: SVGContext) -> CGRect? {
        if let widthAttr = attributes[ignoreCase: "width"],
                  let heightAttr = attributes[ignoreCase: "height"],
                  let width = SVGLengthParser.xAxis.double(string: widthAttr, context: context),
                  let height = SVGLengthParser.yAxis.double(string: heightAttr, context: context) {
          return CGRect(x: 0.0, y: 0.0, width: width, height: height)
        }
        return nil
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

    static func parsePreserveAspectRatio(string: String?, context: SVGContext, defaultValue: SVGPreserveAspectRatio) -> SVGPreserveAspectRatio {
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
        return SVGPreserveAspectRatio(scaling: parseScaling("xMidYMid"))
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
