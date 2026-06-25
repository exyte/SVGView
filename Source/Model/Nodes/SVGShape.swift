#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGShape: SVGNode {

#if os(WASI) || os(Linux) || os(Android)
    public var fill: SVGPaint?
    public var stroke: SVGStroke?
#else
    @Published public var fill: SVGPaint?
    @Published public var stroke: SVGStroke?
#endif

    override func serialize(_ serializer: Serializer) {
        fill?.serialize(key: "fill", serializer: serializer)
        serializer.add("stroke", stroke)
        serializer.add("marker-start", markerStart)
        serializer.add("marker-mid", markerMid)
        serializer.add("marker-end", markerEnd)
        super.serialize(serializer)
    }
}
