import SwiftUI

public class SVGStroke: SerializableBlock {

    public let fill: SVGPaint
    public let width: CGFloat
    public let cap: CGLineCap
    public let join: CGLineJoin
    public let miterLimit: CGFloat
    public let dashes: [CGFloat]
    public let offset: CGFloat

    public init(fill: SVGPaint = SVGColor.black, width: CGFloat = 1, cap: CGLineCap = .butt, join: CGLineJoin = .miter, miterLimit: CGFloat = 4, dashes: [CGFloat] = [], offset: CGFloat = 0.0) {
        self.fill = fill
        self.width = width
        self.cap = cap
        self.join = join
        self.miterLimit = miterLimit
        self.dashes = dashes
        self.offset = offset
    }

    public func toSwiftUI() -> StrokeStyle {
        StrokeStyle(lineWidth: width,
                    lineCap: cap,
                    lineJoin: join,
                    miterLimit: miterLimit,
                    dash: dashes,
                    dashPhase: offset)
    }

    func serialize(_ serializer: Serializer) {
        fill.serialize(key: "fill", serializer: serializer)
        serializer.add("width", width, 1)
        serializer.add("cap", cap)
        serializer.add("join", join)
        serializer.add("offset", offset, 0)
        serializer.add("miterLimit", miterLimit, 4)
        serializer.add("dashes", dashes.serialized)
    }
}
