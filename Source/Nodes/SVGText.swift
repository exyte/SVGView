import SwiftUI

public class SVGText: SVGNode, ObservableObject {

    @Published public var text: String
    @Published public var font: SVGFont?
    @Published public var fill: SVGPaint?
    @Published public var stroke: SVGStroke?
    @Published public var textAnchor: HorizontalAlignment = .leading
    //@Published public var baseline: Baseline

    public init(text: String, font: SVGFont? = nil, fill: SVGPaint? = SVGColor.black, stroke: SVGStroke? = nil, textAnchor: HorizontalAlignment = .leading, /*baseline: Baseline = .top,*/ transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGUserSpaceNode? = nil, mask: SVGNode? = nil) {
        self.text = text
        self.font = font
        self.fill = fill
        self.stroke = stroke
        self.textAnchor = textAnchor
        super.init(transform: transform, opaque: opaque, opacity: opacity, clip: clip, mask: mask)
    }

    override public func toSwiftUI() -> AnyView {
        AnyView(SVGTextView(model: self))
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("text", text).add("font", font).add("textAnchor", textAnchor)
        fill?.serialize(key: "fill", serializer: serializer)
        serializer.add("stroke", stroke)
        super.serialize(serializer)
    }
}

struct SVGTextView: View {

    @ObservedObject var model: SVGText

    public var body: some View {
        Text(model.text)
            .font(model.font?.toSwiftUI())
            .lineLimit(1)
            .alignmentGuide(.leading) { d in d[model.textAnchor] }
            .alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
            .position(x: 0, y: 0) // just to specify that positioning is global, actual coords are in transform
            .apply(paint: model.fill)
            .transformEffect(model.transform)
            .frame(alignment: .topLeading)
    }
}
