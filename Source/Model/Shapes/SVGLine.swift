#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGLine: SVGShape {

    #if os(WASI) || os(Linux) || os(Android)
    public var x1: CGFloat
    public var y1: CGFloat
    public var x2: CGFloat
    public var y2: CGFloat
    #else
    @Published public var x1: CGFloat
    @Published public var y1: CGFloat
    @Published public var x2: CGFloat
    @Published public var y2: CGFloat
    #endif

    public init(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    public init(x1: CGFloat = 0, y1: CGFloat = 0, x2: CGFloat = 0, y2: CGFloat = 0) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    override public func frame() -> CGRect {
        return CGRect(x: min(x1, x2), y: min(y1, y2), width: abs(x1 - x2), height: abs(y1 - y2))
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("x1", x1, 0).add("y1", y1, 0).add("x2", x2, 0).add("y2", y2, 0)
        super.serialize(serializer)
    }

    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGLineView(model: self)
    }
    #endif
}

#if canImport(SwiftUI)
extension SVGLine: ObservableObject {}
struct SVGLineView: View {

    @ObservedObject var model = SVGLine()

    public var body: some View {
        line.toSwiftUI(model: model)
    }

    private var line: MBezierPath {
        let line = MBezierPath()
        line.move(to: CGPoint(x: model.x1, y: model.y1))
        line.addLine(to: CGPoint(x: model.x2, y: model.y2))
        return line
    }
}
#endif

