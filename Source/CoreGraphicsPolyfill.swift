//
//  CoreGraphicsPolyfills.swift
//  SVGView
//
//  Created by khoi on 10/5/25.
//

import Foundation

#if os(WASI) || os(Linux) || os(Android)
    private let KAPPA: CGFloat = 0.5522847498  // 4 *(sqrt(2) -1)/3

    public struct CGAffineTransform: Equatable {
        public var a, b, c, d, tx, ty: CGFloat

        public init(a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat, tx: CGFloat, ty: CGFloat) {

            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.tx = tx
            self.ty = ty
        }
    }

    public enum CGLineJoin: UInt32 {

        case miter
        case round
        case bevel

        public init() { self = .miter }
    }

    public enum CGLineCap: UInt32 {

        case butt
        case round
        case square

        public init() { self = .butt }
    }

    /// A graphics path is a mathematical description of a series of shapes or lines.
    public class CGPath {

        public typealias Element = PathElement

        public var elements: [Element]

        public init(elements: [Element] = []) {

            self.elements = elements
        }
    }

    // MARK: - Supporting Types

    /// A path element.
    public enum PathElement {

        /// The path element that starts a new subpath. The element holds a single point for the destination.
        case moveToPoint(CGPoint)

        /// The path element that adds a line from the current point to a new point.
        /// The element holds a single point for the destination.
        case addLineToPoint(CGPoint)

        /// The path element that adds a quadratic curve from the current point to the specified point.
        /// The element holds a control point and a destination point.
        case addQuadCurveToPoint(CGPoint, CGPoint)

        /// The path element that adds a cubic curve from the current point to the specified point.
        /// The element holds two control points and a destination point.
        case addCurveToPoint(CGPoint, CGPoint, CGPoint)

        /// The path element that closes and completes a subpath. The element does not contain any points.
        case closeSubpath
    }

    extension CGPath {

        public var boundingBoxOfPath: CGRect {
            var minX = CGFloat.infinity
            var minY = CGFloat.infinity
            var maxX = -CGFloat.infinity
            var maxY = -CGFloat.infinity

            for element in elements {
                switch element {
                case .moveToPoint(let point),
                    .addLineToPoint(let point):
                    minX = min(minX, point.x)
                    minY = min(minY, point.y)
                    maxX = max(maxX, point.x)
                    maxY = max(maxY, point.y)

                case .addQuadCurveToPoint(let control, let point):
                    minX = min(minX, control.x, point.x)
                    minY = min(minY, control.y, point.y)
                    maxX = max(maxX, control.x, point.x)
                    maxY = max(maxY, control.y, point.y)

                case .addCurveToPoint(let control1, let control2, let point):
                    minX = min(minX, control1.x, control2.x, point.x)
                    minY = min(minY, control1.y, control2.y, point.y)
                    maxX = max(maxX, control1.x, control2.x, point.x)
                    maxY = max(maxY, control1.y, control2.y, point.y)

                case .closeSubpath:
                    break
                }
            }

            return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }

        public func applyWithBlock(_ block: (UnsafePointer<CGPathElement>) -> Void) {
            for element in elements {
                let cgPathElement: CGPathElement
                
                switch element {
                case .moveToPoint(let point):
                    cgPathElement = CGPathElement(
                        type: .moveToPoint,
                        points: (point, CGPoint.zero, CGPoint.zero)
                    )
                    
                case .addLineToPoint(let point):
                    cgPathElement = CGPathElement(
                        type: .addLineToPoint,
                        points: (point, CGPoint.zero, CGPoint.zero)
                    )
                    
                case .addQuadCurveToPoint(let control, let point):
                    cgPathElement = CGPathElement(
                        type: .addQuadCurveToPoint,
                        points: (control, point, CGPoint.zero)
                    )
                    
                case .addCurveToPoint(let control1, let control2, let point):
                    cgPathElement = CGPathElement(
                        type: .addCurveToPoint,
                        points: (control1, control2, point)
                    )
                    
                case .closeSubpath:
                    cgPathElement = CGPathElement(
                        type: .closeSubpath,
                        points: (CGPoint.zero, CGPoint.zero, CGPoint.zero)
                    )
                }
                
                withUnsafePointer(to: cgPathElement) { pointer in
                    block(pointer)
                }
            }
        }

        public func addRect(_ rect: CGRect) {

            let newElements: [Element] = [
                .moveToPoint(CGPoint(x: rect.minX, y: rect.minY)),
                .addLineToPoint(CGPoint(x: rect.maxX, y: rect.minY)),
                .addLineToPoint(CGPoint(x: rect.maxX, y: rect.maxY)),
                .addLineToPoint(CGPoint(x: rect.minX, y: rect.maxY)),
                .closeSubpath,
            ]

            elements.append(contentsOf: newElements)
        }

        public func addEllipse(in rect: CGRect) {

            var p = CGPoint()
            var p1 = CGPoint()
            var p2 = CGPoint()

            let hdiff = rect.width / 2 * KAPPA
            let vdiff = rect.height / 2 * KAPPA

            p = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height)
            elements.append(.moveToPoint(p))

            p = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height / 2)
            p1 = CGPoint(x: rect.origin.x + rect.width / 2 - hdiff, y: rect.origin.y + rect.height)
            p2 = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height / 2 + vdiff)
            elements.append(.addCurveToPoint(p1, p2, p))

            p = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y)
            p1 = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2 - vdiff)
            p2 = CGPoint(x: rect.origin.x + rect.size.width / 2 - hdiff, y: rect.origin.y)
            elements.append(.addCurveToPoint(p1, p2, p))

            p = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2)
            p1 = CGPoint(x: rect.origin.x + rect.size.width / 2 + hdiff, y: rect.origin.y)
            p2 = CGPoint(
                x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2 - vdiff)
            elements.append(.addCurveToPoint(p1, p2, p))

            p = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height)
            p1 = CGPoint(
                x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2 + vdiff)
            p2 = CGPoint(
                x: rect.origin.x + rect.size.width / 2 + hdiff, y: rect.origin.y + rect.size.height)
            elements.append(.addCurveToPoint(p1, p2, p))
        }

        public func move(to point: CGPoint) {

            elements.append(.moveToPoint(point))
        }

        public func addLine(to point: CGPoint) {

            elements.append(.addLineToPoint(point))
        }

        public func addCurve(to endPoint: CGPoint, control1: CGPoint, control2: CGPoint) {

            elements.append(.addCurveToPoint(control1, control2, endPoint))
        }

        public func addQuadCurve(to endPoint: CGPoint, control: CGPoint) {

            elements.append(.addQuadCurveToPoint(control, endPoint))
        }

        public func closeSubpath() {

            elements.append(.closeSubpath)
        }
    }

    public struct CGPathElement {
        public var type: CGPathElementType

        public var points: [CGPoint] 

        public init(type: CGPathElementType, points: (CGPoint, CGPoint, CGPoint)) {
            self.type = type
            self.points = [points.0, points.1, points.2]
        }
    }
    
    /// Rules for determining which regions are interior to a path.
    ///
    /// When filling a path, regions that a fill rule defines as interior to the path are painted.
    /// When clipping with a path, regions interior to the path remain visible after clipping.
    public enum CGPathFillRule: Int {

        /// A rule that considers a region to be interior to a path based on the number of times it is enclosed by path elements.
        case evenOdd

        /// A rule that considers a region to be interior to a path if the winding number for that region is nonzero.
        case winding
    }

    /// The type of element found in a path.
    public enum CGPathElementType {

        /// The path element that starts a new subpath. The element holds a single point for the destination.
        case moveToPoint

        /// The path element that adds a line from the current point to a new point.
        /// The element holds a single point for the destination.
        case addLineToPoint

        /// The path element that adds a quadratic curve from the current point to the specified point.
        /// The element holds a control point and a destination point.
        case addQuadCurveToPoint

        /// The path element that adds a cubic curve from the current point to the specified point.
        /// The element holds two control points and a destination point.
        case addCurveToPoint

        /// The path element that closes and completes a subpath. The element does not contain any points.
        case closeSubpath
    }

    extension CGPoint {

        @inline(__always)
        public func applying(_ t: CGAffineTransform) -> CGPoint {
            return CGPoint(
                x: t.a * x + t.c * y + t.tx,
                y: t.b * x + t.d * y + t.ty)
        }
    }

    extension CGAffineTransform {
        public var isIdentity: Bool {
            self == CGAffineTransform.identity
        }

        public static var identity: CGAffineTransform {
            CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
        }

        public init(translationX tx: CGFloat, y ty: CGFloat) {
            self.init(a: 1, b: 0, c: 0, d: 1, tx: tx, ty: ty)
        }

        public init(scaleX sx: CGFloat, y sy: CGFloat) {
            self.init(a: sx, b: 0, c: 0, d: sy, tx: 0, ty: 0)
        }

        public init(rotationAngle angle: CGFloat) {
            self.init(a: cos(angle), b: sin(angle), c: -sin(angle), d: cos(angle), tx: 0, ty: 0)
        }

        public func translatedBy(x: CGFloat, y: CGFloat) -> CGAffineTransform {
            return self.concatenating(CGAffineTransform(translationX: x, y: y))
        }

        public func concatenating(_ t: CGAffineTransform) -> CGAffineTransform {
            return CGAffineTransform(
                a: a * t.a + b * t.c,
                b: a * t.b + b * t.d,
                c: c * t.a + d * t.c,
                d: c * t.b + d * t.d,
                tx: tx * t.a + ty * t.c + t.tx,
                ty: tx * t.b + ty * t.d + t.ty
            )
        }

        public func scaledBy(x: CGFloat, y: CGFloat) -> CGAffineTransform {
            return self.concatenating(CGAffineTransform(scaleX: x, y: y))
        }

        public func rotated(by angle: CGFloat) -> CGAffineTransform {
            return self.concatenating(CGAffineTransform(rotationAngle: angle))
        }
    }

    public class MBezierPath {
        public var cgPath: CGPath

        public init() {
            self.cgPath = CGPath()
        }

        public init?(rect: CGRect) {
            self.cgPath = CGPath()
            self.cgPath.addRect(rect)
        }

        public init?(ovalIn rect: CGRect) {
            self.cgPath = CGPath()
            self.cgPath.addEllipse(in: rect)
        }

        public init(
            arcCenter: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat,
            clockwise: Bool
        ) {
            self.cgPath = CGPath()
            MBezierPath.addArcTo(
                path: self.cgPath, center: arcCenter, radius: radius, startAngle: startAngle,
                endAngle: endAngle, clockwise: clockwise)
        }

        public func move(to point: CGPoint) {
            cgPath.move(to: point)
        }

        public func addLine(to point: CGPoint) {
            cgPath.addLine(to: point)
        }

        public func addCurve(
            to endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint
        ) {
            cgPath.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
        }

        public func addQuadCurve(to endPoint: CGPoint, controlPoint: CGPoint) {
            cgPath.addQuadCurve(to: endPoint, control: controlPoint)
        }

        public func addArc(
            withCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat,
            clockwise: Bool
        ) {
            MBezierPath.addArcTo(
                path: self.cgPath, center: center, radius: radius, startAngle: startAngle,
                endAngle: endAngle, clockwise: clockwise)
        }

        public func append(_ path: MBezierPath) {
            cgPath.elements.append(contentsOf: path.cgPath.elements)
        }

        public func close() {
            cgPath.closeSubpath()
        }

        public func apply(_ transform: CGAffineTransform) {
            var newElements: [CGPath.Element] = []
            for element in cgPath.elements {
                switch element {
                case .moveToPoint(let point):
                    newElements.append(.moveToPoint(point.applying(transform)))
                case .addLineToPoint(let point):
                    newElements.append(.addLineToPoint(point.applying(transform)))
                case .addQuadCurveToPoint(let control, let point):
                    newElements.append(
                        .addQuadCurveToPoint(control.applying(transform), point.applying(transform))
                    )
                case .addCurveToPoint(let control1, let control2, let point):
                    newElements.append(
                        .addCurveToPoint(
                            control1.applying(transform), control2.applying(transform),
                            point.applying(transform)))
                case .closeSubpath:
                    newElements.append(.closeSubpath)
                }
            }
            self.cgPath.elements = newElements
        }

        public var isEmpty: Bool {
            return cgPath.elements.isEmpty
        }

        public var bounds: CGRect {
            return cgPath.boundingBoxOfPath
        }

        static func addArcTo(
            path: CGPath, center: CGPoint, radius: CGFloat, startAngle: CGFloat,
            endAngle: CGFloat, clockwise: Bool
        ) {
            var deltaAngle: CGFloat
            if clockwise {
                deltaAngle = endAngle - startAngle
                while deltaAngle < 0 { deltaAngle += 2 * .pi }
            } else {  // Counter-clockwise
                deltaAngle = endAngle - startAngle
                while deltaAngle > 0 { deltaAngle -= 2 * .pi }
            }

            if abs(deltaAngle) < 1e-6 { return }  // Essentially no arc

            let numSegments = Swift.max(1, Int(ceil(abs(deltaAngle) / (.pi / 2.0))))  // Max 90deg segments
            let segmentAngleSweep = deltaAngle / CGFloat(numSegments)

            var currentAngle = startAngle

            let initialPoint = CGPoint(
                x: center.x + radius * cos(currentAngle), y: center.y + radius * sin(currentAngle))

            if path.elements.isEmpty || (path.elements.last?.isCloseSubpath ?? false) {
                path.move(to: initialPoint)
            } else if let lastElement = path.elements.last, let lastPoint = lastElement.lastPoint,
                lastPoint != initialPoint
            {
                path.addLine(to: initialPoint)
            }

            for _ in 0..<numSegments {
                let nextAngle = currentAngle + segmentAngleSweep
                let L = radius * (4.0 / 3.0) * tan(abs(segmentAngleSweep) / 4.0)

                let cp1_centerRelative = CGPoint(
                    x: radius * cos(currentAngle) - L * sin(currentAngle),
                    y: radius * sin(currentAngle) + L * cos(currentAngle)
                )
                let cp2_centerRelative = CGPoint(
                    x: radius * cos(nextAngle) + L * sin(nextAngle),
                    y: radius * sin(nextAngle) - L * cos(nextAngle)
                )

                let endPoint_abs = CGPoint(
                    x: center.x + radius * cos(nextAngle), y: center.y + radius * sin(nextAngle))
                let cp1_abs = CGPoint(
                    x: center.x + cp1_centerRelative.x, y: center.y + cp1_centerRelative.y)
                let cp2_abs = CGPoint(
                    x: center.x + cp2_centerRelative.x, y: center.y + cp2_centerRelative.y)

                path.addCurve(to: endPoint_abs, control1: cp1_abs, control2: cp2_abs)
                currentAngle = nextAngle
            }
        }
    }

    extension CGPath.Element {
        var lastPoint: CGPoint? {
            switch self {
            case .moveToPoint(let p): return p
            case .addLineToPoint(let p): return p
            case .addQuadCurveToPoint(_, let p): return p
            case .addCurveToPoint(_, _, let p): return p
            case .closeSubpath: return nil
            }
        }
        var isCloseSubpath: Bool {
            if case .closeSubpath = self { return true }
            return false
        }
    }

#else
    import CoreGraphics
    public typealias CGLineJoin = CoreGraphics.CGLineJoin
    public typealias CGLineCap = CoreGraphics.CGLineCap
    public typealias CGPathFillRule = CoreGraphics.CGPathFillRule
    public typealias CGPath = CoreGraphics.CGPath
    public typealias CGAffineTransform = CoreGraphics.CGAffineTransform
#endif
