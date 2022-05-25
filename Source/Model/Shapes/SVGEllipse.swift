import SwiftUI

public class SVGEllipse: SVGShape, ObservableObject {

    @Published public var cx: CGFloat
    @Published public var cy: CGFloat
    @Published public var rx: CGFloat
    @Published public var ry: CGFloat

    public init(cx: CGFloat = 0, cy: CGFloat = 0, rx: CGFloat = 0, ry: CGFloat = 0) {
        self.cx = cx
        self.cy = cy
        self.rx = rx
        self.ry = ry
    }

    override public func frame() -> CGRect {
        CGRect(x: cx - rx, y: cy - ry, width: 2*rx, height: 2*ry)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("cx", cx, 0).add("cy", cy, 0).add("rx", rx, 0).add("ry", ry, 0)
        super.serialize(serializer)
    }

    public func contentView() -> some View {
        SVGEllipseView(model: self)
    }
}

struct SVGEllipseView: View {

    @ObservedObject var model = SVGEllipse()

    public var body: some View {
        Ellipse()
            .applySVGStroke(stroke: model.stroke)
            .frame(width: 2 * model.rx, height: 2 * model.ry)
            .position(x: model.cx, y: model.cy)
            .applyShapeAttributes(model: model)
    }
}

