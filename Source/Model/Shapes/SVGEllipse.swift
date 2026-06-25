#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGEllipse: SVGShape {
    #if os(WASI) || os(Linux) || os(Android)
    public var cx: CGFloat
    public var cy: CGFloat
    public var rx: CGFloat
    public var ry: CGFloat
    #else
    @Published public var cx: CGFloat
    @Published public var cy: CGFloat
    @Published public var rx: CGFloat
    @Published public var ry: CGFloat
    #endif
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

    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGEllipseView(model: self)
    }
    #endif
}

#if canImport(SwiftUI)
extension SVGEllipse: ObservableObject {}
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
#endif

