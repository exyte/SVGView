import SwiftUI

public class SVGPath: SVGShape, ObservableObject {

    @Published public var segments: [PathSegment]
    @Published public var fillRule: CGPathFillRule

    public init(segments: [PathSegment] = [], fillRule: CGPathFillRule = .winding) {
        self.segments = segments
        self.fillRule = fillRule
        super.init()

        normalize()
    }

    override public func bounds() -> CGRect {
        self.toBezierPath().cgPath.boundingBoxOfPath
    }

    override public func toSwiftUI() -> AnyView {
        AnyView(SVGPathView(model: self))
    }

    override func serialize(_ serializer: Serializer) {
        let path = segments.map { s in "\(s.type)\(s.data.compactMap { $0.serialize() }.joined(separator: ","))" }.joined(separator: " ")
        serializer.add("path", path)
        serializer.add("fillRule", fillRule)
        super.serialize(serializer)
    }

    private func normalize() {
        let bounds = self.toBezierPath().cgPath.boundingBoxOfPath
        let x = bounds.minX
        let y = bounds.minY

        // subtract origin from every coordinate
        var normalizedSegments: [PathSegment] = []
        for i in segments.indices {
            let segment = segments[i]
            var data = segment.data
            switch segment.type {
            case .M:
                data[0] -= x
                data[1] -= y
            case .L:
                data[0] -= x
                data[1] -= y
            case .H:
                data[0] -= x
            case .V:
                data[0] -= y
            case .C:
                data[0] -= x
                data[1] -= y
                data[2] -= x
                data[3] -= y
                data[4] -= x
                data[5] -= y
            case .S:
                data[0] -= x
                data[1] -= y
                data[2] -= x
                data[3] -= y
            case .Q:
                data[0] -= x
                data[1] -= y
                data[2] -= x
                data[3] -= y
            case .T:
                data[0] -= x
                data[1] -= y
            case .A:
                data[5] -= x
                data[6] -= y
            case .E:
                data[0] -= x
                data[1] -= y
            default:
                break
            }

            // if path starts from relative segment
            if i == 0 {
                switch segment.type {
                case .m:
                    data[0] -= x
                    data[1] -= y
                case .l:
                    data[0] -= x
                    data[1] -= y
                case .h:
                    data[0] -= x
                case .v:
                    data[0] -= y
                case .c:
                    data[0] -= x
                    data[1] -= y
                    data[2] -= x
                    data[3] -= y
                    data[4] -= x
                    data[5] -= y
                case .s:
                    data[0] -= x
                    data[1] -= y
                    data[2] -= x
                    data[3] -= y
                case .q:
                    data[0] -= x
                    data[1] -= y
                    data[2] -= x
                    data[3] -= y
                case .t:
                    data[0] -= x
                    data[1] -= y
                case .a:
                    data[5] -= x
                    data[6] -= y
                case .e:
                    data[0] -= x
                    data[1] -= y
                default:
                    break
                }
            }

            let normalized = PathSegment(type: segment.type, data: data)
            normalizedSegments.append(normalized)
        }
        self.segments = normalizedSegments

        // move normalized path to origin
        transform = transform.translatedBy(x: x, y: y)
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
        Path(self.cgPath)
            .applySVGStroke(stroke: model.stroke, eoFill: eoFill)
            .applyShapeAttributes(model: model)
            .applyIf(model.fill is SVGGradient) {
                $0.frame(width: model.bounds().width, height: model.bounds().height)
                    .coordinateSpace(name: "GradientSpace")
            }
    }
}

