//
//  Path.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 23/07/2020.
//

import SwiftUI

#if os(OSX)
import AppKit
public typealias MBezierPath = NSBezierPath
#else
public typealias MBezierPath = UIBezierPath
#endif

public enum PathSegmentType {
    case M
    case L
    case C
    case Q
    case A
    case z
    case H
    case V
    case S
    case T
    case m
    case l
    case c
    case q
    case a
    case h
    case v
    case s
    case t
    case E
    case e
}

public class PathSegment {

    public let type: PathSegmentType
    public let data: [CGFloat]

    public init(type: PathSegmentType = .M, data: [CGFloat] = []) {
        self.type = type
        self.data = data
    }

    open func isAbsolute() -> Bool {
        switch type {
        case .M, .L, .H, .V, .C, .S, .Q, .T, .A, .E:
            return true
        default:
            return false
        }
    }
}

class PathReader {

    private let input: String
    private var current: UnicodeScalar?
    private var previous: UnicodeScalar?
    private var iterator: String.UnicodeScalarView.Iterator

    init(input: String) {
        self.input = input
        self.iterator = input.unicodeScalars.makeIterator()
    }

    public func read() -> [PathSegment] {
        readNext()
        var segments = [PathSegment]()
        while let array = readSegments() {
            segments.append(contentsOf: array)
        }
        return segments
    }

    private func readSegments() -> [PathSegment]? {
        if let type = readSegmentType() {
            let argCount = getArgCount(segment: type)
            if argCount == 0 {
                return [PathSegment(type: type)]
            }
            var result = [PathSegment]()
            let data: [CGFloat]
            if type == .a || type == .A {
                data = readDataOfASegment()
            } else {
                data = readData()
            }
            var index = 0
            var isFirstSegment = true
            while index < data.count {
                let end = index + argCount
                if end > data.count {
                    // TODO need to generate error:
                    // "Path '\(type)' has invalid number of arguments: \(data.count)"
                    break
                }
                var currentType = type
                if type == .M && !isFirstSegment {
                    currentType = .L
                }
                if type == .m && !isFirstSegment {
                    currentType = .l
                }
                result.append(PathSegment(type: currentType, data: Array(data[index..<end])))
                isFirstSegment = false
                index = end
            }
            return result
        }
        return nil
    }

    private func readData() -> [CGFloat] {
        var data = [CGFloat]()
        while true {
            skipSpaces()
            if let value = readNum() {
                data.append(value)
            } else {
                return data
            }
        }
    }

    private func readDataOfASegment() -> [CGFloat] {
        let argCount = getArgCount(segment: .A)
        var data: [CGFloat] = []
        var index = 0
        while true {
            skipSpaces()
            let value: CGFloat?
            let indexMod = index % argCount
            if indexMod == 3 || indexMod == 4 {
                value = readFlag()
            } else {
                value = readNum()
            }
            guard let CGFloatValue = value else {
                return data
            }
            data.append(CGFloatValue)
            index += 1
        }
        return data
    }

    private func skipSpaces() {
        var ch = current
        while ch != nil && "\n\r\t ,".contains(String(ch!)) {
            ch = readNext()
        }
    }

    private func readFlag() -> CGFloat? {
        guard let ch = current else {
            return .none
        }
        readNext()
        switch ch {
        case "0":
            return 0
        case "1":
            return 1
        default:
            return .none
        }
    }

    fileprivate func readNum() -> CGFloat? {
        guard let ch = current else {
            return .none
        }

        guard ch >= "0" && ch <= "9" || ch == "." || ch == "-" else {
            return .none
        }

        var chars = [ch]
        var hasDot = ch == "."
        while let ch = readDigit(&hasDot) {
            chars.append(ch)
        }

        var buf = ""
        buf.unicodeScalars.append(contentsOf: chars)
        guard let value = buf.cgFloatValue else {
            return .none
        }
        return value
    }

    fileprivate func readDigit(_ hasDot: inout Bool) -> UnicodeScalar? {
        if let ch = readNext() {
            if (ch >= "0" && ch <= "9") || ch == "e" || (previous == "e" && ch == "-") {
                return ch
            } else if ch == "." && !hasDot {
                hasDot = true
                return ch
            }
        }
        return nil
    }

    fileprivate func isNum(ch: UnicodeScalar, hasDot: inout Bool) -> Bool {
        switch ch {
        case "0"..."9":
            return true
        case ".":
            if hasDot {
                return false
            }
            hasDot = true
        default:
            return true
        }
        return false
    }

    @discardableResult
    private func readNext() -> UnicodeScalar? {
        previous = current
        current = iterator.next()
        return current
    }

    private func isAcceptableSeparator(_ ch: UnicodeScalar?) -> Bool {
        if let ch = ch {
            return "\n\r\t ,".contains(String(ch))
        }
        return false
    }

    private func readSegmentType() -> PathSegmentType? {
        while true {
            if let type = getPathSegmentType() {
                readNext()
                return type
            }
            if readNext() == nil {
                return nil
            }
        }
    }

    fileprivate func getPathSegmentType() -> PathSegmentType? {
        if let ch = current {
            switch ch {
            case "M":
                return .M
            case "m":
                return .m
            case "L":
                return .L
            case "l":
                return .l
            case "C":
                return .C
            case "c":
                return .c
            case "Q":
                return .Q
            case "q":
                return .q
            case "A":
                return .A
            case "a":
                return .a
            case "z", "Z":
                return .z
            case "H":
                return .H
            case "h":
                return .h
            case "V":
                return .V
            case "v":
                return .v
            case "S":
                return .S
            case "s":
                return .s
            case "T":
                return .T
            case "t":
                return .t
            default:
                break
            }
        }
        return nil
    }

    fileprivate func getArgCount(segment: PathSegmentType) -> Int {
        switch segment {
        case .H, .h, .V, .v:
            return 1
        case .M, .m, .L, .l, .T, .t:
            return 2
        case .S, .s, .Q, .q:
            return 4
        case .C, .c:
            return 6
        case .A, .a:
            return 7
        default:
            return 0
        }
    }
}

extension SVGPath {

    func toBezierPath() -> MBezierPath {

        func calcAngle(ux: CGFloat, uy: CGFloat, vx: CGFloat, vy: CGFloat) -> CGFloat {
            let sign = copysign(1, ux * vy - uy * vx)
            let value = (ux * vx + uy * vy) / (sqrt(ux * ux + uy * uy) * sqrt(vx * vx + vy * vy))
            if value < -1 {
                return sign * .pi
            } else if value > 1 {
                return 0
            } else {
                return sign * acos(value)
            }
        }

        func num2bool(_ CGFloat: CGFloat) -> Bool {
            return CGFloat > 0.5 ? true : false
        }

        let bezierPath = MBezierPath()

        var currentPoint: CGPoint?
        var cubicPoint: CGPoint?
        var quadrPoint: CGPoint?
        var initialPoint: CGPoint?

        func M(_ x: CGFloat, y: CGFloat) {
            let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
            bezierPath.move(to: point)
            setInitPoint(point)
        }

        func m(_ x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                let next = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)
                bezierPath.move(to: next)
                setInitPoint(next)
            } else {
                M(x, y: y)
            }
        }

        func L(_ x: CGFloat, y: CGFloat) {
            lineTo(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }

        func l(_ x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y))
            } else {
                L(x, y: y)
            }
        }

        func H(_ x: CGFloat) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(x), y: CGFloat(cur.y)))
            }
        }

        func h(_ x: CGFloat) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(cur.y)))
            }
        }

        func V(_ y: CGFloat) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(cur.x), y: CGFloat(y)))
            }
        }

        func v(_ y: CGFloat) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(cur.x), y: CGFloat(y) + cur.y))
            }
        }

        func lineTo(_ p: CGPoint) {
            bezierPath.addLine(to: p)
            setPoint(p)
        }

        func c(_ x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                let endPoint = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)
                let controlPoint1 = CGPoint(x: CGFloat(x1) + cur.x, y: CGFloat(y1) + cur.y)
                let controlPoint2 = CGPoint(x: CGFloat(x2) + cur.x, y: CGFloat(y2) + cur.y)
                bezierPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                setCubicPoint(endPoint, cubic: controlPoint2)
            }
        }

        func C(_ x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, x: CGFloat, y: CGFloat) {
            let endPoint = CGPoint(x: CGFloat(x), y: CGFloat(y))
            let controlPoint1 = CGPoint(x: CGFloat(x1), y: CGFloat(y1))
            let controlPoint2 = CGPoint(x: CGFloat(x2), y: CGFloat(y2))
            bezierPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            setCubicPoint(endPoint, cubic: controlPoint2)
        }

        func s(_ x2: CGFloat, y2: CGFloat, x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                let nextCubic = CGPoint(x: CGFloat(x2) + cur.x, y: CGFloat(y2) + cur.y)
                let next = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)

                var xy1: CGPoint?
                if let curCubicVal = cubicPoint {
                    xy1 = CGPoint(x: CGFloat(2 * cur.x) - curCubicVal.x, y: CGFloat(2 * cur.y) - curCubicVal.y)
                } else {
                    xy1 = cur
                }
                bezierPath.addCurve(to: next, controlPoint1: xy1!, controlPoint2: nextCubic)
                setCubicPoint(next, cubic: nextCubic)
            }
        }

        func S(_ x2: CGFloat, y2: CGFloat, x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                let nextCubic = CGPoint(x: CGFloat(x2), y: CGFloat(y2))
                let next = CGPoint(x: CGFloat(x), y: CGFloat(y))
                var xy1: CGPoint?
                if let curCubicVal = cubicPoint {
                    xy1 = CGPoint(x: CGFloat(2 * cur.x) - curCubicVal.x, y: CGFloat(2 * cur.y) - curCubicVal.y)
                } else {
                    xy1 = cur
                }
                bezierPath.addCurve(to: next, controlPoint1: xy1!, controlPoint2: nextCubic)
                setCubicPoint(next, cubic: nextCubic)
            }
        }

        func q(_ x1: CGFloat, y1: CGFloat, x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                let dx = CGFloat(cur.x)
                let dy = CGFloat(cur.y)
                Q(x1 + dx, y1: y1 + dy, x: x + dx, y: y + dy)
            }
        }

        func Q(_ x1: CGFloat, y1: CGFloat, x: CGFloat, y: CGFloat) {
            let endPoint = CGPoint(x: x, y: y)
            let controlPoint = CGPoint(x: x1, y: y1)
            bezierPath.addQuadCurve(to: endPoint, controlPoint: controlPoint)
            setQuadrPoint(endPoint, quadr: controlPoint)
        }

        func t(_ x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                let next = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)
                var quadr: CGPoint?
                if let curQuadr = quadrPoint {
                    quadr = CGPoint(x: 2 * cur.x - curQuadr.x, y: 2 * cur.y - curQuadr.y)
                } else {
                    quadr = cur
                }
                bezierPath.addQuadCurve(to: next, controlPoint: quadr!)
                setQuadrPoint(next, quadr: quadr!)
            }
        }

        func T(_ x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                let next = CGPoint(x: CGFloat(x), y: CGFloat(y))
                var quadr: CGPoint?
                if let curQuadr = quadrPoint {
                    quadr = CGPoint(x: 2 * cur.x - curQuadr.x, y: 2 * cur.y - curQuadr.y)
                } else {
                    quadr = cur
                }
                bezierPath.addQuadCurve(to: next, controlPoint: quadr!)
                setQuadrPoint(next, quadr: quadr!)
            }
        }

        func a(_ rx: CGFloat, ry: CGFloat, angle: CGFloat, largeArc: Bool, sweep: Bool, x: CGFloat, y: CGFloat) {
            if let cur = currentPoint {
                A(rx, ry: ry, angle: angle, largeArc: largeArc, sweep: sweep, x: x + CGFloat(cur.x), y: y + CGFloat(cur.y))
            }
        }

        func A(_ _rx: CGFloat, ry _ry: CGFloat, angle _angle: CGFloat, largeArc: Bool, sweep: Bool, x: CGFloat, y: CGFloat) {
            let angle = _angle * .pi / 180

            if let cur = currentPoint {
                let x1 = CGFloat(cur.x)
                let y1 = CGFloat(cur.y)

                // find arc center coordinates and points angles as per
                // http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
                if _rx == 0 || _ry == 0 {
                    L(x, y: y)
                } else {
                    var rx = abs(_rx)
                    var ry = abs(_ry)
                    let x1_ = cos(angle) * (x1 - x) / 2 + sin(angle) * (y1 - y) / 2
                    let y1_ = -1 * sin(angle) * (x1 - x) / 2 + cos(angle) * (y1 - y) / 2

                    let rCheck = (x1_ * x1_) / (rx * rx) + (y1_ * y1_) / (ry * ry)
                    if rCheck > 1 {
                        rx = sqrt(rCheck) * rx
                        ry = sqrt(rCheck) * ry
                    }

                    // make sure the value under the root is positive
                    let underroot = (rx * rx * ry * ry - rx * rx * y1_ * y1_ - ry * ry * x1_ * x1_)
                        / (rx * rx * y1_ * y1_ + ry * ry * x1_ * x1_)
                    var bigRoot = (underroot > 0) ? sqrt(underroot) : 0
                    bigRoot = (bigRoot <= 1e-2) ? 0 : bigRoot
                    let coef: CGFloat = (sweep != largeArc) ? 1 : -1
                    let cx_ = coef * bigRoot * rx * y1_ / ry
                    let cy_ = -1 * coef * bigRoot * ry * x1_ / rx
                    let cx = cos(angle) * cx_ - sin(angle) * cy_ + (x1 + x) / 2
                    let cy = sin(angle) * cx_ + cos(angle) * cy_ + (y1 + y) / 2

                    let t1 = calcAngle(ux: 1, uy: 0, vx: (x1_ - cx_) / rx, vy: (y1_ - cy_) / ry)
                    var delta = calcAngle(ux: (x1_ - cx_) / rx, uy: (y1_ - cy_) / ry, vx: (-x1_ - cx_) / rx, vy: (-y1_ - cy_) / ry)
                    let pi2 = CGFloat.pi * 2
                    if delta > 0 {
                        delta = delta.truncatingRemainder(dividingBy: pi2)
                        if !sweep {
                            delta -= pi2
                        }
                    } else if delta < 0 {
                        delta = -1 * ((-1 * delta).truncatingRemainder(dividingBy: pi2))
                        if sweep {
                            delta += pi2
                        }
                    }
                    E(cx - rx, y: cy - ry, w: 2 * rx, h: 2 * ry, startAngle: t1, arcAngle: delta, rotation: angle)
                    setPoint(CGPoint(x: CGFloat(x), y: CGFloat(y)))
                }
            }
        }

        func E(_ x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, startAngle: CGFloat, arcAngle: CGFloat, rotation: CGFloat = 0) {
            let extent = CGFloat(startAngle)
            let end = extent + CGFloat(arcAngle)
            let cx = CGFloat(x + w / 2)
            let cy = CGFloat(y + h / 2)
            if w == h && rotation == 0 {
                bezierPath.addArc(withCenter: CGPoint(x: cx, y: cy), radius: CGFloat(w / 2), startAngle: extent, endAngle: end, clockwise: arcAngle >= 0)
            } else {
                let maxSize = CGFloat(max(w, h))
                let path = MBezierPath(arcCenter: CGPoint.zero, radius: maxSize / 2, startAngle: extent, endAngle: end, clockwise: arcAngle >= 0)

                var transform = CGAffineTransform(translationX: cx, y: cy)
                transform = transform.rotated(by: CGFloat(rotation))
                path.apply(transform.scaledBy(x: CGFloat(w) / maxSize, y: CGFloat(h) / maxSize))

                bezierPath.append(path)
            }
        }

        func e(_ x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, startAngle: CGFloat, arcAngle: CGFloat) {
            // TODO: only circle now
            if let cur = currentPoint {
                E(x + CGFloat(cur.x), y: y + CGFloat(cur.y), w: w, h: h, startAngle: startAngle, arcAngle: arcAngle)
            }
        }

        func Z() {
            if let initPoint = initialPoint {
                lineTo(initPoint)
            }
            bezierPath.close()
        }

        func setQuadrPoint(_ p: CGPoint, quadr: CGPoint) {
            currentPoint = p
            quadrPoint = quadr
            cubicPoint = nil
        }

        func setCubicPoint(_ p: CGPoint, cubic: CGPoint) {
            currentPoint = p
            cubicPoint = cubic
            quadrPoint = nil
        }

        func setInitPoint(_ p: CGPoint) {
            setPoint(p)
            initialPoint = p
        }

        func setPoint(_ p: CGPoint) {
            currentPoint = p
            cubicPoint = nil
            quadrPoint = nil
        }

        // TODO: think about this
        for part in segments {
            var data = part.data
            switch part.type {
            case .M:
                M(data[0], y: data[1])
                data.removeSubrange(Range(uncheckedBounds: (lower: 0, upper: 2)))
                while data.count >= 2 {
                    L(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .m:
                m(data[0], y: data[1])
                data.removeSubrange((0 ..< 2))
                while data.count >= 2 {
                    l(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .L:
                while data.count >= 2 {
                    L(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .l:
                while data.count >= 2 {
                    l(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .H:
                H(data[0])
            case .h:
                h(data[0])
            case .V:
                V(data[0])
            case .v:
                v(data[0])
            case .C:
                while data.count >= 6 {
                    C(data[0], y1: data[1], x2: data[2], y2: data[3], x: data[4], y: data[5])
                    data.removeSubrange((0 ..< 6))
                }
            case .c:
                while data.count >= 6 {
                    c(data[0], y1: data[1], x2: data[2], y2: data[3], x: data[4], y: data[5])
                    data.removeSubrange((0 ..< 6))
                }
            case .S:
                while data.count >= 4 {
                    S(data[0], y2: data[1], x: data[2], y: data[3])
                    data.removeSubrange((0 ..< 4))
                }
            case .s:
                while data.count >= 4 {
                    s(data[0], y2: data[1], x: data[2], y: data[3])
                    data.removeSubrange((0 ..< 4))
                }
            case .Q:
                Q(data[0], y1: data[1], x: data[2], y: data[3])
            case .q:
                q(data[0], y1: data[1], x: data[2], y: data[3])
            case .T:
                T(data[0], y: data[1])
            case .t:
                t(data[0], y: data[1])
            case .A:
                A(data[0], ry: data[1], angle: data[2], largeArc: num2bool(data[3]), sweep: num2bool(data[4]), x: data[5], y: data[6])
            case .a:
                a(data[0], ry: data[1], angle: data[2], largeArc: num2bool(data[3]), sweep: num2bool(data[4]), x: data[5], y: data[6])
            case .E:
                E(data[0], y: data[1], w: data[2], h: data[3], startAngle: data[4], arcAngle: data[5])
            case .e:
                e(data[0], y: data[1], w: data[2], h: data[3], startAngle: data[4], arcAngle: data[5])
            case .z:
                Z()
            }
        }
        return bezierPath
    }


}
