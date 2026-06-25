#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGCircle: SVGShape {

    #if os(WASI) || os(Linux) || os(Android)
    public var cx: CGFloat
    public var cy: CGFloat
    public var r: CGFloat
    #else
    @Published public var cx: CGFloat
    @Published public var cy: CGFloat
    @Published public var r: CGFloat
    #endif
    

    public init(cx: CGFloat = 0, cy: CGFloat = 0, r: CGFloat = 0) {
        self.cx = cx
        self.cy = cy
        self.r = r
    }

    override public func frame() -> CGRect {
        CGRect(x: cx - r, y: cy - r, width: 2*r, height: 2*r)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("cx", cx, 0).add("cy", cy, 0).add("r", r, 0)
        super.serialize(serializer)
    }

    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGCircleView(model: self)
    }
    #endif
}

#if canImport(SwiftUI)
extension SVGCircle: ObservableObject {}
struct SVGCircleView: View {

    @ObservedObject var model = SVGCircle()

    public var body: some View {
        Circle()
            .applySVGStroke(stroke: model.stroke)
            .applyShapeAttributes(model: model)
            .frame(width: 2 * model.r, height: 2 * model.r)
            .position(x: model.cx, y: model.cy)
    }
}
#endif
