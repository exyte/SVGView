//
//  SVGShapeParser.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import CoreGraphics

class SVGShapeParser: SVGBaseElementParser {

    override func doParse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        guard let locus = parseLocus(context: context) else { return nil }
        locus.fill = SVGHelper.parseFill(context.styles, context.index)
        locus.stroke = SVGHelper.parseStroke(context.styles, index: context.index)
        return locus
    }

    /// should be overwritten by inheritor
    func parseLocus(context: SVGNodeContext) -> SVGShape? {
        return nil
    }

}

class SVGRectParser: SVGShapeParser {
    override func parseLocus(context: SVGNodeContext) -> SVGShape? {
        let x = SVGHelper.parseCGFloat(context.properties, "x")
        let y = SVGHelper.parseCGFloat(context.properties, "y")
        let width = SVGHelper.parseCGFloat(context.properties, "width")
        let height = SVGHelper.parseCGFloat(context.properties, "height")
        let rxOpt = SVGHelper.parseOptCGFloat(context.properties, "rx")
        let ryOpt = SVGHelper.parseOptCGFloat(context.properties, "ry")
        let rx = rxOpt ?? ryOpt ?? 0
        let ry = ryOpt ?? rxOpt ?? 0
        return SVGRect(x: x, y: y, width: width, height: height, rx: rx, ry: ry)
    }
}

class SVGCircleParser: SVGShapeParser {
    override func parseLocus(context: SVGNodeContext) -> SVGShape? {
        let radius = SVGHelper.parseCGFloat(context.properties, "r")
        let x = SVGHelper.parseCGFloat(context.properties, "cx")
        let y = SVGHelper.parseCGFloat(context.properties, "cy")
        return SVGCircle(cx: x, cy: y, r: radius)
    }
}

class SVGEllipseParser: SVGShapeParser {
    override func parseLocus(context: SVGNodeContext) -> SVGShape? {
        let x = SVGHelper.parseCGFloat(context.properties, "cx")
        let y = SVGHelper.parseCGFloat(context.properties, "cy")
        let rx = SVGHelper.parseCGFloat(context.properties, "rx")
        let ry = SVGHelper.parseCGFloat(context.properties, "ry")
        return SVGEllipse(cx: x, cy: y, rx: rx, ry: ry)
    }
}

class SVGLineParser: SVGShapeParser {
    override func parseLocus(context: SVGNodeContext) -> SVGShape? {
        let x1 = SVGHelper.parseCGFloat(context.properties, "x1")
        let y1 = SVGHelper.parseCGFloat(context.properties, "y1")
        let x2 = SVGHelper.parseCGFloat(context.properties, "x2")
        let y2 = SVGHelper.parseCGFloat(context.properties, "y2")
        return SVGLine(x1, y1, x2, y2)
    }
}

class SVGPolygonParser: SVGShapeParser {
    override func parseLocus(context: SVGNodeContext) -> SVGShape? {
        let points = SVGHelper.parsePointsArray(context.property("points") ?? "")
        return SVGPolygon(points)
    }
}

class SVGPolylineParser: SVGShapeParser {
    override func parseLocus(context: SVGNodeContext) -> SVGShape? {
        let points = SVGHelper.parsePointsArray(context.property("points") ?? "")
        return SVGPolyline(points)
    }
}

class SVGPathParser: SVGShapeParser {
    override func parseLocus(context: SVGNodeContext) -> SVGShape? {
        let segments = PathReader(input: context.property("d") ?? "").read()
        return SVGPath(segments: segments, fillRule: context.style("fill-rule") == "evenodd" ? .evenOdd : .winding)
    }
}
