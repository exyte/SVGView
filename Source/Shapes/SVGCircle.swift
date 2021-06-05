import SwiftUI

public class SVGCircle: SVGShape, ObservableObject {

    @Published public var cx: CGFloat
    @Published public var cy: CGFloat
    @Published public var r: CGFloat

    public init(cx: CGFloat = 0, cy: CGFloat = 0, r: CGFloat = 0) {
        self.cx = cx
        self.cy = cy
        self.r = r
    }

    override public func bounds() -> CGRect {
        CGRect(x: cx - r, y: cy - r, width: 2*r, height: 2*r)
    }

    override public func toSwiftUI() -> AnyView {
        AnyView(SVGCircleView(model: self))
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("cx", cx, 0).add("cy", cy, 0).add("r", r, 0)
        super.serialize(serializer)
    }
}

struct SVGCircleView: View {

    @ObservedObject var model = SVGCircle()

    public var body: some View {
        Circle()
            .applySVGStroke(stroke: model.stroke)
            .frame(width: 2 * model.r, height: 2 * model.r)
            .position(x: model.cx, y: model.cy)
            .applyShapeAttributes(model: model)
            .applyIf(model.fill is SVGGradient) {
                $0.coordinateSpace(name: "GradientSpace")
            }
    }
}
