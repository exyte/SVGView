import SwiftUI

public class SVGPath: SVGShape, ObservableObject {

    @Published public var segments: [PathSegment]
    @Published public var fillRule: CGPathFillRule

    public init(segments: [PathSegment] = [], fillRule: CGPathFillRule = .winding) {
        self.segments = segments
        self.fillRule = fillRule
    }

    override public func frame() -> CGRect {
        toBezierPath().cgPath.boundingBoxOfPath
    }

    override public func bounds() -> CGRect {
        frame()
    }

    override func serialize(_ serializer: Serializer) {
        let path = segments.map { s in "\(s.type)\(s.data.compactMap { $0.serialize() }.joined(separator: ","))" }.joined(separator: " ")
        serializer.add("path", path)
        serializer.add("fillRule", fillRule)
        super.serialize(serializer)
    }

    public func contentView() -> some View {
        SVGPathView(model: self)
    }
}

struct SVGPathView: View {

    @ObservedObject var model = SVGPath()

    public var body: some View {
        model.toBezierPath().toSwiftUI(model: model, eoFill: model.fillRule == .evenOdd)
    }
}

extension MBezierPath {

    func toSwiftUI(model: SVGShape, eoFill: Bool = false) -> some View {
        let isGradient = model.fill is SVGGradient
        let bounds = isGradient ? model.bounds() : CGRect.zero
        return Path(self.cgPath)
            .applySVGStroke(stroke: model.stroke, eoFill: eoFill)
            .applyShapeAttributes(model: model)
            .applyIf(isGradient) {
                $0.frame(width: bounds.width, height: bounds.height)
                    .position(x: 0, y: 0)
                    .offset(x: bounds.width/2, y: bounds.height/2)
            }
    }
}

