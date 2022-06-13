//
//  SVGParserExtensions.swift
//  SVGView
//
//  Created by Yuri Strot on 25.05.2022.
//

import CoreGraphics

extension CGFloat {

    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }

}

extension String {

    var cgFloatValue: CGFloat? {
        if let value = Double(self) {
            return CGFloat(value)
        }
        return .none
    }
}

extension CGAffineTransform {

    func shear(shx: CGFloat = 0, shy: CGFloat = 0) -> CGAffineTransform {
        return CGAffineTransform(a: a + c * shy, b: b + d * shy,
                                 c: a * shx + c, d: b * shx + d, tx: tx, ty: ty)
    }

}

extension Dictionary where Key == String {

    subscript(ignoreCase key: Key) -> Value? {
        get {
            if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
                return self[k]
            }
            return nil
        }
    }

}
