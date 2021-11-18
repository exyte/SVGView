import SwiftUI

public class SVGShape: SVGNode {

    @Published public var fill: SVGPaint?
    @Published public var stroke: SVGStroke?

    override func serialize(_ serializer: Serializer) {
        fill?.serialize(key: "fill", serializer: serializer)
        serializer.add("stroke", stroke)
        super.serialize(serializer)
    }
}
