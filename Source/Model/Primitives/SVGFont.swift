#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
#endif

public class SVGFont: SerializableBlock {

    public let name: String
    public let size: CGFloat
    public let weight: String

    public init(name: String = "Serif", size: CGFloat = 16, weight: String = "normal") {
        self.name = name
        self.size = size
        self.weight = weight
    }
    
    #if canImport(SwiftUI)
    public func toSwiftUI() -> Font {
        return Font.custom(name, size: size)//.weight(fontWeight)
    }
    #endif

    func serialize(_ serializer: Serializer) {
        serializer.add("name", name, "Serif").add("size", size, 16).add("weight", weight, "normal")
    }
}


