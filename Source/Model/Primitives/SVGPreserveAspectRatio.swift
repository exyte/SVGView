//
//  SVGPreserveAspectRatio.swift
//  SVGView
//
//  Created by Yuriy Strot on 20.01.2021.
//

import SwiftUI

public class SVGPreserveAspectRatio {

    public let scaling: Scaling
    public let xAlign: Align
    public let yAlign: Align

    public init(scaling: Scaling = .meet, xAlign: Align = .mid, yAlign: Align = .mid) {
        self.scaling = scaling
        self.xAlign = xAlign
        self.yAlign = yAlign
    }

    public func layout(size: CGSize, into sizeToFitIn: CGSize) -> CGAffineTransform {
        return layout(rect: CGRect(origin: CGPoint.zero, size: size), into: sizeToFitIn)
    }

    public func layout(rect: CGRect, into sizeToFitIn: CGSize) -> CGAffineTransform {
        let newSize = scaling.fit(size: rect.size, into: sizeToFitIn)
        let sx = newSize.width / rect.width
        let sy = newSize.height / rect.height
        let dx = xAlign.align(outer: sizeToFitIn.width, inner: newSize.width) / sx
        let dy = yAlign.align(outer: sizeToFitIn.height, inner: newSize.height) / sy
        return CGAffineTransform(scaleX: sx, y: sy).translatedBy(x: dx - rect.minX, y: dy - rect.minY)
    }

    public func slice(size: CGSize, into rectToFitIn: CGRect) -> CGRect? {
        if scaling == .slice {
            // setup new clipping to slice extra bits
            let newSize = Scaling.meet.fit(size: size, into: rectToFitIn)
            let newX = rectToFitIn.minX + xAlign.align(outer: rectToFitIn.width, inner: newSize.width)
            let newY = rectToFitIn.minY + yAlign.align(outer: rectToFitIn.height, inner: newSize.height)
            return CGRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
        }
        return nil
    }

    public enum Align: String, SerializableEnum {

        case mid
        case min
        case max

        public func align(outer: CGFloat, inner: CGFloat) -> CGFloat {
            switch self {
            case .mid:
                return (outer - inner) / 2
            case .max:
                return outer - inner
            default:
                return 0
            }
        }

        public func align(size: CGFloat) -> CGFloat {
            return align(outer: size, inner: 0)
        }

    }

    public enum Scaling: String, SerializableEnum {

        case meet
        case slice
        case none

        public func fit(size: CGSize, into sizeToFitIn: CGSize) -> CGSize {
            if self == .none {
                return CGSize(width: sizeToFitIn.width, height: sizeToFitIn.height)
            }

            let widthRatio = sizeToFitIn.width / size.width
            let heightRatio = sizeToFitIn.height / size.height
            let keepHeight = self == .meet ? heightRatio < widthRatio : heightRatio > widthRatio

            if keepHeight {
                return CGSize(width: size.width * heightRatio, height: sizeToFitIn.height)
            } else {
                return CGSize(width: sizeToFitIn.width, height: size.height * widthRatio)
            }

        }

        public func fit(rect: CGRect, into rectToFitIn: CGRect) -> CGSize {
            return fit(size: rect.size, into: rectToFitIn.size)
        }

        public func fit(size: CGSize, into rectToFitIn: CGRect) -> CGSize {
            return fit(size: size, into: rectToFitIn.size)
        }

    }

}
