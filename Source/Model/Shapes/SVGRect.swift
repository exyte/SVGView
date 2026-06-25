#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGRect: SVGShape {

    #if os(WASI) || os(Linux) || os(Android)
    public var x: CGFloat
    public var y: CGFloat
    public var width: CGFloat
    public var height: CGFloat
    public var rx: CGFloat = 0
    public var ry: CGFloat = 0
    #else   
    @Published public var x: CGFloat
    @Published public var y: CGFloat
    @Published public var width: CGFloat
    @Published public var height: CGFloat
    @Published public var rx: CGFloat = 0
    @Published public var ry: CGFloat = 0
    #endif
    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, rx: CGFloat = 0, ry: CGFloat = 0) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rx = rx
        self.ry = ry
    }

    public init(_ rect: CGRect) {
        self.x = rect.minX
        self.y = rect.minY
        self.width = rect.width
        self.height = rect.height
    }

    override public func frame() -> CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("x", x, 0).add("y", y, 0).add("width", width, 0).add("height", height, 0)
        serializer.add("rx", rx, 0).add("ry", ry, 0)
        super.serialize(serializer)
    }
    
    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGRectView(model: self)
    }
    #endif
}

#if canImport(SwiftUI)
extension SVGRect: ObservableObject {}
struct SVGRectView: View {

    @ObservedObject var model: SVGRect

    public var body: some View {
        RoundedRectangle(cornerSize: CGSize(width: model.rx, height: model.ry))
            .applySVGStroke(stroke: model.stroke)
            .applyShapeAttributes(model: model)
            .frame(width: model.width, height: model.height)
            .position(x: model.x, y: model.y)
            .offset(x: model.width/2, y: model.height/2)
    }
}
#endif
