//
//  PolyfillTests.swift
//  SVGView
//
//  Tests for CoreGraphicsPolyfill.swift - comprehensive testing of the CoreGraphics
//  polyfill implementation for WASI/Linux platforms where CoreGraphics is not available.
//
//  These tests verify:
//  - CGAffineTransform operations (identity, translation, scaling, rotation, concatenation)
//  - CGPath functionality (basic operations, bounding box calculation, shape addition)
//  - MBezierPath operations (initialization, path building, transformations, arc handling)
//  - PathElement enum and extensions
//  - Edge cases and error handling
//
//  On platforms with native CoreGraphics (macOS, iOS), only a fallback test runs
//  since the polyfill types are aliases to the native CoreGraphics types.
//

import XCTest

@testable import SVGView

final class PolyfillTests: XCTestCase {
    
    #if os(WASI) || os(Linux) || os(Android)
    
    // MARK: - CGAffineTransform Tests
    
    func testAffineTransformIdentity() {
        let identity = CGAffineTransform.identity
        XCTAssertEqual(identity.a, 1)
        XCTAssertEqual(identity.b, 0)
        XCTAssertEqual(identity.c, 0)
        XCTAssertEqual(identity.d, 1)
        XCTAssertEqual(identity.tx, 0)
        XCTAssertEqual(identity.ty, 0)
        XCTAssertTrue(identity.isIdentity)
    }
    
    func testAffineTransformTranslation() {
        let transform = CGAffineTransform(translationX: 10, y: 20)
        XCTAssertEqual(transform.a, 1)
        XCTAssertEqual(transform.b, 0)
        XCTAssertEqual(transform.c, 0)
        XCTAssertEqual(transform.d, 1)
        XCTAssertEqual(transform.tx, 10)
        XCTAssertEqual(transform.ty, 20)
        XCTAssertFalse(transform.isIdentity)
    }
    
    func testAffineTransformScale() {
        let transform = CGAffineTransform(scaleX: 2, y: 3)
        XCTAssertEqual(transform.a, 2)
        XCTAssertEqual(transform.b, 0)
        XCTAssertEqual(transform.c, 0)
        XCTAssertEqual(transform.d, 3)
        XCTAssertEqual(transform.tx, 0)
        XCTAssertEqual(transform.ty, 0)
    }
    
    func testAffineTransformRotation() {
        let transform = CGAffineTransform(rotationAngle: .pi / 2)
        XCTAssertEqual(transform.a, cos(.pi / 2), accuracy: 1e-10)
        XCTAssertEqual(transform.b, sin(.pi / 2), accuracy: 1e-10)
        XCTAssertEqual(transform.c, -sin(.pi / 2), accuracy: 1e-10)
        XCTAssertEqual(transform.d, cos(.pi / 2), accuracy: 1e-10)
        XCTAssertEqual(transform.tx, 0)
        XCTAssertEqual(transform.ty, 0)
    }
    
    func testPointTransformation() {
        let point = CGPoint(x: 1, y: 2)
        let transform = CGAffineTransform(translationX: 10, y: 20)
        let transformedPoint = point.applying(transform)
        
        XCTAssertEqual(transformedPoint.x, 11)
        XCTAssertEqual(transformedPoint.y, 22)
    }
    
    func testTransformConcatenation() {
        let transform1 = CGAffineTransform(translationX: 5, y: 10)
        let transform2 = CGAffineTransform(scaleX: 2, y: 3)
        let combined = transform1.concatenating(transform2)
        
        XCTAssertEqual(combined.a, 2)
        XCTAssertEqual(combined.d, 3)
        XCTAssertEqual(combined.tx, 10)
        XCTAssertEqual(combined.ty, 30)
    }
    
    func testTransformFluent() {
        let transform = CGAffineTransform.identity
            .translatedBy(x: 10, y: 20)
            .scaledBy(x: 2, y: 3)
            .rotated(by: .pi / 4)
        
        XCTAssertFalse(transform.isIdentity)
        XCTAssertNotEqual(transform.tx, 0)
        XCTAssertNotEqual(transform.ty, 0)
    }
    
    func testComplexTransform() {
        let point = CGPoint(x: 5, y: 5)
        let transform = CGAffineTransform(rotationAngle: .pi / 4)
            .translatedBy(x: 10, y: 10)
            .scaledBy(x: 2, y: 2)
        
        let transformedPoint = point.applying(transform)
        XCTAssertNotEqual(transformedPoint.x, point.x)
        XCTAssertNotEqual(transformedPoint.y, point.y)
    }
    
    // MARK: - CGLineJoin and CGLineCap Tests
    
    func testLineJoinEnum() {
        let miterJoin = CGLineJoin.miter
        let roundJoin = CGLineJoin.round
        let bevelJoin = CGLineJoin.bevel
        let defaultJoin = CGLineJoin()
        
        XCTAssertEqual(defaultJoin, .miter)
        XCTAssertNotEqual(miterJoin, roundJoin)
        XCTAssertNotEqual(roundJoin, bevelJoin)
    }
    
    func testLineCapEnum() {
        let buttCap = CGLineCap.butt
        let roundCap = CGLineCap.round
        let squareCap = CGLineCap.square
        let defaultCap = CGLineCap()
        
        XCTAssertEqual(defaultCap, .butt)
        XCTAssertNotEqual(buttCap, roundCap)
        XCTAssertNotEqual(roundCap, squareCap)
    }
    
    // MARK: - CGPath Tests
    
    func testPathElementCreation() {
        let moveElement = PathElement.moveToPoint(CGPoint(x: 0, y: 0))
        let lineElement = PathElement.addLineToPoint(CGPoint(x: 10, y: 10))
        let _ = PathElement.addQuadCurveToPoint(CGPoint(x: 5, y: 5), CGPoint(x: 10, y: 0))
        let _ = PathElement.addCurveToPoint(CGPoint(x: 5, y: 5), CGPoint(x: 7, y: 3), CGPoint(x: 10, y: 0))
        let closeElement = PathElement.closeSubpath
        
        if case .moveToPoint(let point) = moveElement {
            XCTAssertEqual(point.x, 0)
            XCTAssertEqual(point.y, 0)
        } else {
            XCTFail("Expected moveToPoint")
        }
        
        if case .addLineToPoint(let point) = lineElement {
            XCTAssertEqual(point.x, 10)
            XCTAssertEqual(point.y, 10)
        } else {
            XCTFail("Expected addLineToPoint")
        }
        
        if case .closeSubpath = closeElement {
            // Test passes
        } else {
            XCTFail("Expected closeSubpath")
        }
    }
    
    func testPathBasicOperations() {
        let path = CGPath()
        XCTAssertTrue(path.elements.isEmpty)
        
        path.move(to: CGPoint(x: 0, y: 0))
        XCTAssertEqual(path.elements.count, 1)
        
        path.addLine(to: CGPoint(x: 10, y: 10))
        XCTAssertEqual(path.elements.count, 2)
        
        path.closeSubpath()
        XCTAssertEqual(path.elements.count, 3)
    }
    
    func testPathBoundingBox() {
        let path = CGPath()
        path.move(to: CGPoint(x: 5, y: 5))
        path.addLine(to: CGPoint(x: 15, y: 10))
        path.addLine(to: CGPoint(x: 10, y: 20))
        
        let bounds = path.boundingBoxOfPath
        XCTAssertEqual(bounds.minX, 5)
        XCTAssertEqual(bounds.minY, 5)
        XCTAssertEqual(bounds.maxX, 15)
        XCTAssertEqual(bounds.maxY, 20)
        XCTAssertEqual(bounds.width, 10)
        XCTAssertEqual(bounds.height, 15)
    }
    
    func testPathBoundingBoxWithCurves() {
        let path = CGPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: 10, y: 10), control1: CGPoint(x: 5, y: 5), control2: CGPoint(x: 15, y: 8))
        
        let bounds = path.boundingBoxOfPath
        XCTAssertEqual(bounds.minX, 0)
        XCTAssertEqual(bounds.minY, 0)
        XCTAssertEqual(bounds.maxX, 15)
        XCTAssertEqual(bounds.maxY, 10)
    }
    
    func testPathAddRect() {
        let path = CGPath()
        let rect = CGRect(x: 10, y: 20, width: 30, height: 40)
        path.addRect(rect)
        
        XCTAssertEqual(path.elements.count, 5) // move + 3 lines + close
        
        let bounds = path.boundingBoxOfPath
        XCTAssertEqual(bounds, rect)
    }
    
    func testPathAddEllipse() {
        let path = CGPath()
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        path.addEllipse(in: rect)
        
        XCTAssertFalse(path.elements.isEmpty)
        
        let bounds = path.boundingBoxOfPath
        // Ellipse should fit within the rectangle (approximately)
        XCTAssertGreaterThanOrEqual(bounds.minX, rect.minX - 1)
        XCTAssertGreaterThanOrEqual(bounds.minY, rect.minY - 1)
        XCTAssertLessThanOrEqual(bounds.maxX, rect.maxX + 1)
        XCTAssertLessThanOrEqual(bounds.maxY, rect.maxY + 1)
    }
    
    func testPathQuadCurve() {
        let path = CGPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: 10, y: 10), control: CGPoint(x: 5, y: 0))
        
        XCTAssertEqual(path.elements.count, 2)
        
        if case .addQuadCurveToPoint(let control, let end) = path.elements[1] {
            XCTAssertEqual(control.x, 5)
            XCTAssertEqual(control.y, 0)
            XCTAssertEqual(end.x, 10)
            XCTAssertEqual(end.y, 10)
        } else {
            XCTFail("Expected quad curve element")
        }
    }
    
    // MARK: - MBezierPath Tests
    
    func testBezierPathInit() {
        let path = MBezierPath()
        XCTAssertTrue(path.isEmpty)
        XCTAssertTrue(path.cgPath.elements.isEmpty)
    }
    
    func testBezierPathRectInit() {
        let rect = CGRect(x: 10, y: 20, width: 30, height: 40)
        let path = MBezierPath(rect: rect)
        
        XCTAssertNotNil(path)
        XCTAssertFalse(path!.isEmpty)
        XCTAssertEqual(path!.bounds, rect)
    }
    
    func testBezierPathOvalInit() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let path = MBezierPath(ovalIn: rect)
        
        XCTAssertNotNil(path)
        XCTAssertFalse(path!.isEmpty)
    }
    
    func testBezierPathArcInit() {
        let center = CGPoint(x: 50, y: 50)
        let radius: CGFloat = 25
        let path = MBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: .pi,
            clockwise: true
        )
        
        XCTAssertFalse(path.isEmpty)
    }
    
    func testBezierPathOperations() {
        let path = MBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        XCTAssertFalse(path.isEmpty)
        
        path.addLine(to: CGPoint(x: 10, y: 10))
        path.addQuadCurve(to: CGPoint(x: 20, y: 0), controlPoint: CGPoint(x: 15, y: -5))
        path.addCurve(
            to: CGPoint(x: 30, y: 10),
            controlPoint1: CGPoint(x: 25, y: 5),
            controlPoint2: CGPoint(x: 28, y: 8)
        )
        path.close()
        
        XCTAssertEqual(path.cgPath.elements.count, 5)
    }
    
    func testBezierPathTransform() {
        let path = MBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 10))
        
        let originalBounds = path.bounds
        let transform = CGAffineTransform(scaleX: 2, y: 2)
        path.apply(transform)
        
        let newBounds = path.bounds
        XCTAssertEqual(newBounds.width, originalBounds.width * 2, accuracy: 1e-10)
        XCTAssertEqual(newBounds.height, originalBounds.height * 2, accuracy: 1e-10)
    }
    
    func testBezierPathAppend() {
        let path1 = MBezierPath()
        path1.move(to: CGPoint(x: 0, y: 0))
        path1.addLine(to: CGPoint(x: 10, y: 10))
        
        let path2 = MBezierPath()
        path2.move(to: CGPoint(x: 20, y: 20))
        path2.addLine(to: CGPoint(x: 30, y: 30))
        
        let originalCount = path1.cgPath.elements.count
        path1.append(path2)
        
        XCTAssertEqual(path1.cgPath.elements.count, originalCount + path2.cgPath.elements.count)
    }
    
    func testBezierPathArc() {
        let path = MBezierPath()
        let center = CGPoint(x: 50, y: 50)
        let radius: CGFloat = 25
        
        path.addArc(
            withCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        XCTAssertFalse(path.isEmpty)
        XCTAssertGreaterThan(path.cgPath.elements.count, 1)
    }
    
    func testBezierPathArcCounterClockwise() {
        let path = MBezierPath()
        let center = CGPoint(x: 0, y: 0)
        let radius: CGFloat = 10
        
        path.addArc(
            withCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: -.pi / 2,
            clockwise: false
        )
        
        XCTAssertFalse(path.isEmpty)
    }
    
    func testBezierPathFullCircleArc() {
        let path = MBezierPath()
        let center = CGPoint(x: 50, y: 50)
        let radius: CGFloat = 25
        
        path.addArc(
            withCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        
        XCTAssertFalse(path.isEmpty)
        XCTAssertGreaterThan(path.cgPath.elements.count, 4) // Should have multiple segments
    }
    
    // MARK: - PathElement Extension Tests
    
    func testPathElementLastPoint() {
        let moveElement = PathElement.moveToPoint(CGPoint(x: 5, y: 10))
        let lineElement = PathElement.addLineToPoint(CGPoint(x: 15, y: 20))
        let closeElement = PathElement.closeSubpath
        
        XCTAssertEqual(moveElement.lastPoint, CGPoint(x: 5, y: 10))
        XCTAssertEqual(lineElement.lastPoint, CGPoint(x: 15, y: 20))
        XCTAssertNil(closeElement.lastPoint)
    }
    
    func testPathElementIsCloseSubpath() {
        let moveElement = PathElement.moveToPoint(CGPoint(x: 0, y: 0))
        let closeElement = PathElement.closeSubpath
        
        XCTAssertFalse(moveElement.isCloseSubpath)
        XCTAssertTrue(closeElement.isCloseSubpath)
    }
    
    func testPathElementLastPointWithCurves() {
        let quadElement = PathElement.addQuadCurveToPoint(CGPoint(x: 5, y: 5), CGPoint(x: 10, y: 10))
        let curveElement = PathElement.addCurveToPoint(CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 2), CGPoint(x: 3, y: 3))
        
        XCTAssertEqual(quadElement.lastPoint, CGPoint(x: 10, y: 10))
        XCTAssertEqual(curveElement.lastPoint, CGPoint(x: 3, y: 3))
    }
    
    // MARK: - CGPathElement Tests
    
    func testCGPathElementCreation() {
        let element = CGPathElement(
            type: .moveToPoint,
            points: (CGPoint(x: 1, y: 2), CGPoint.zero, CGPoint.zero)
        )
        
        XCTAssertEqual(element.type, .moveToPoint)
        XCTAssertEqual(element.points[0], CGPoint(x: 1, y: 2))
    }
    
    // MARK: - CGPathElementType Tests
    
    func testCGPathElementTypeEnum() {
        let moveType = CGPathElementType.moveToPoint
        let lineType = CGPathElementType.addLineToPoint
        let quadType = CGPathElementType.addQuadCurveToPoint
        let curveType = CGPathElementType.addCurveToPoint
        let closeType = CGPathElementType.closeSubpath
        
        // Ensure all enum cases are distinct
        XCTAssertNotEqual(moveType, lineType)
        XCTAssertNotEqual(lineType, quadType)
        XCTAssertNotEqual(quadType, curveType)
        XCTAssertNotEqual(curveType, closeType)
        XCTAssertNotEqual(closeType, moveType)
    }
    
    // MARK: - CGPathFillRule Tests
    
    func testCGPathFillRuleEnum() {
        let evenOdd = CGPathFillRule.evenOdd
        let winding = CGPathFillRule.winding
        
        XCTAssertNotEqual(evenOdd, winding)
        XCTAssertNotEqual(evenOdd.rawValue, winding.rawValue)
    }
    
    func testCGPathFillRuleRawValues() {
        // Test that raw values are distinct and valid
        let evenOdd = CGPathFillRule.evenOdd
        let winding = CGPathFillRule.winding
        
        XCTAssertNotNil(CGPathFillRule(rawValue: evenOdd.rawValue))
        XCTAssertNotNil(CGPathFillRule(rawValue: winding.rawValue))
        XCTAssertEqual(CGPathFillRule(rawValue: evenOdd.rawValue), evenOdd)
        XCTAssertEqual(CGPathFillRule(rawValue: winding.rawValue), winding)
    }
    
    // MARK: - MBezierPath Static Method Tests
    
    func testMBezierPathAddArcToStatic() {
        let path = CGPath()
        let center = CGPoint(x: 10, y: 10)
        let radius: CGFloat = 5
        
        // Test static addArcTo method directly
        MBezierPath.addArcTo(
            path: path,
            center: center,
            radius: radius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        XCTAssertFalse(path.elements.isEmpty)
        XCTAssertGreaterThan(path.elements.count, 1)
        
        // First element should be move to starting point
        if case .moveToPoint(let point) = path.elements.first {
            XCTAssertEqual(point.x, center.x + radius, accuracy: 1e-10)
            XCTAssertEqual(point.y, center.y, accuracy: 1e-10)
        } else {
            XCTFail("Expected first element to be moveToPoint")
        }
    }
    
    func testMBezierPathAddArcToStaticWithExistingPath() {
        let path = CGPath()
        path.move(to: CGPoint(x: 20, y: 20))
        path.addLine(to: CGPoint(x: 25, y: 25))
        
        let originalCount = path.elements.count
        
        // Add arc to existing path
        MBezierPath.addArcTo(
            path: path,
            center: CGPoint(x: 0, y: 0),
            radius: 10,
            startAngle: 0,
            endAngle: .pi,
            clockwise: false
        )
        
        // Should have added more elements
        XCTAssertGreaterThan(path.elements.count, originalCount)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyPathBounds() {
        let path = CGPath()
        let bounds = path.boundingBoxOfPath
        
        XCTAssertTrue(bounds.width.isInfinite || bounds.width.isNaN)
        XCTAssertTrue(bounds.height.isInfinite || bounds.height.isNaN)
    }
    
    func testSinglePointPathBounds() {
        let path = CGPath()
        path.move(to: CGPoint(x: 10, y: 20))
        
        let bounds = path.boundingBoxOfPath
        XCTAssertEqual(bounds.origin.x, 10)
        XCTAssertEqual(bounds.origin.y, 20)
        XCTAssertEqual(bounds.width, 0)
        XCTAssertEqual(bounds.height, 0)
    }
    
    func testZeroRadiusArc() {
        let path = MBezierPath()
        path.addArc(
            withCenter: CGPoint(x: 0, y: 0),
            radius: 0,
            startAngle: 0,
            endAngle: .pi,
            clockwise: true
        )
        
        // With zero radius, it creates move + curve elements all at center point
        XCTAssertFalse(path.isEmpty)
        XCTAssertEqual(path.cgPath.elements.count, 3) // move + 2 curves for π angle
        
        // First element should be moveToPoint at center
        if case .moveToPoint(let point) = path.cgPath.elements[0] {
            XCTAssertEqual(point.x, 0)
            XCTAssertEqual(point.y, 0)
        } else {
            XCTFail("Expected first element to be moveToPoint")
        }
        
        // All curve elements should have all points at center
        for element in path.cgPath.elements.dropFirst() {
            if case .addCurveToPoint(let cp1, let cp2, let end) = element {
                XCTAssertEqual(cp1.x, 0)
                XCTAssertEqual(cp1.y, 0)
                XCTAssertEqual(cp2.x, 0)
                XCTAssertEqual(cp2.y, 0)
                XCTAssertEqual(end.x, 0)
                XCTAssertEqual(end.y, 0)
            } else {
                XCTFail("Expected curve element")
            }
        }
    }
    
    func testVerySmallAngleArc() {
        let path = MBezierPath()
        path.addArc(
            withCenter: CGPoint(x: 0, y: 0),
            radius: 10,
            startAngle: 0,
            endAngle: 1e-10,
            clockwise: true
        )
        
        // Should handle very small angles (essentially no arc)
        XCTAssertTrue(path.isEmpty || path.cgPath.elements.count <= 2)
    }
    
    func testIdenticalStartEndAngles() {
        let path = MBezierPath()
        path.addArc(
            withCenter: CGPoint(x: 0, y: 0),
            radius: 10,
            startAngle: .pi / 4,
            endAngle: .pi / 4,
            clockwise: true
        )
        
        // Should handle identical start and end angles
        XCTAssertTrue(path.isEmpty || path.cgPath.elements.count <= 1)
    }
    
    func testNegativeRectDimensions() {
        let path = CGPath()
        let rect = CGRect(x: 10, y: 10, width: -5, height: -5)
        path.addRect(rect)
        
        // Should handle negative dimensions
        XCTAssertFalse(path.elements.isEmpty)
    }
    
    #else
    
    func testPolyfillNotNeeded() {
        // On platforms with CoreGraphics, polyfill types should be aliases
        XCTAssertTrue(true, "CoreGraphics polyfill not needed on this platform")
    }
    
    #endif
}
