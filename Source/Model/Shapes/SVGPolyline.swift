#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGPolyline: SVGShape {
    #if os(WASI) || os(Linux) || os(Android)
    public var points: [CGPoint]
    #else
    @Published public var points: [CGPoint]
    #endif

    public init(_ points: [CGPoint]) {
        self.points = points
    }

    public init(points: [CGPoint] = []) {
        self.points = points
    }

    override public func frame() -> CGRect {
        guard !points.isEmpty else {
            return .zero
        }

        var minX = CGFloat(Int16.max)
        var minY = CGFloat(Int16.max)
        var maxX = CGFloat(Int16.min)
        var maxY = CGFloat(Int16.min)

        for point in points {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }

        return CGRect(x: minX, y: minY,
                      width: maxX - minX,
                      height: maxY - minY)
    }

    public override func bounds() -> CGRect {
        let frame = frame()
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("points", points.serialized)
        super.serialize(serializer)
    }

    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGPolylineView(model: self)
    }
    #endif
}

#if canImport(SwiftUI)
extension SVGPolyline: ObservableObject {}
struct SVGPolylineView: View {

    @ObservedObject var model = SVGPolyline()

    public var body: some View {
        path?.toSwiftUI(model: model)
    }

    private var path: MBezierPath? {
        guard let first = model.points.first else { return nil }
        let path = MBezierPath()
        path.move(to: CGPoint(x: first.x, y: first.y))
        for i in 1..<model.points.count {
            let point = model.points[i]
            path.addLine(to: CGPoint(x: point.x, y: point.y))
        }
        return path
    }
}
#endif

