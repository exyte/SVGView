import SwiftUI

public class SVGPolyline: SVGShape, ObservableObject {

    @Published public var points: [CGPoint]

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

        var minX = CGFloat(INT16_MAX)
        var minY = CGFloat(INT16_MAX)
        var maxX = CGFloat(INT16_MIN)
        var maxY = CGFloat(INT16_MIN)

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

    public func contentView() -> some View {
        SVGPolylineView(model: self)
    }
}

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

