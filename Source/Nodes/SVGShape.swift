import SwiftUI

public class SVGShape: SVGNode {

    @Published public var fill: SVGPaint?
    @Published public var stroke: SVGStroke?

    // override in subclasses
    override public func toSwiftUI() -> AnyView {
        fatalError("Base shape SVGShape is not convertable to SwiftUI")
    }

    override func serialize(_ serializer: Serializer) {
        fill?.serialize(key: "fill", serializer: serializer)
        serializer.add("stroke", stroke)
        super.serialize(serializer)
    }
}
