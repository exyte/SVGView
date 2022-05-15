import SwiftUI

public class SVGText: SVGNode, ObservableObject {

    @Published public var text: String
    @Published public var font: SVGFont?
    @Published public var fill: SVGPaint?
    @Published public var stroke: SVGStroke?
    @Published public var textAnchor: HorizontalAlignment = .leading

    public init(text: String, font: SVGFont? = nil, fill: SVGPaint? = SVGColor.black, stroke: SVGStroke? = nil, textAnchor: HorizontalAlignment = .leading, transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGUserSpaceNode? = nil, mask: SVGNode? = nil) {
        self.text = text
        self.font = font
        self.fill = fill
        self.stroke = stroke
        self.textAnchor = textAnchor
        super.init(transform: transform, opaque: opaque, opacity: opacity, clip: clip, mask: mask)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("text", text).add("font", font).add("textAnchor", textAnchor)
        fill?.serialize(key: "fill", serializer: serializer)
        serializer.add("stroke", stroke)
        super.serialize(serializer)
    }
    
    public func contentView() -> some View {
        SVGTextView(model: self)
    }
}

struct SVGTextView: View {

    @ObservedObject var model: SVGText

    public var body: some View {
        if let stroke = model.stroke, let fill = model.fill {
            ZStack {
                // TODO: just a temporary fix, should be replaced with a better solution
                let hw = stroke.width / 2
                filledText(fill: stroke.fill).offset(x: hw, y: hw)
                filledText(fill: stroke.fill).offset(x: -hw, y: -hw)
                filledText(fill: stroke.fill).offset(x: -hw, y: hw)
                filledText(fill: stroke.fill).offset(x: hw, y: -hw)
                filledText(fill: fill)
            }
        } else {
            filledText(fill: model.fill)
        }
    }

    private func filledText(fill: SVGPaint?) -> some View {
        Text(model.text)
           .font(model.font?.toSwiftUI())
           .lineLimit(1)
           .alignmentGuide(.leading) { d in d[model.textAnchor] }
           .alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
           .position(x: 0, y: 0) // just to specify that positioning is global, actual coords are in transform
           .apply(paint: fill)
           .transformEffect(model.transform)
           .frame(alignment: .topLeading)
    }
}
