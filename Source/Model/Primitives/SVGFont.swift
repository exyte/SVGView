import SwiftUI

public class SVGFont: SerializableBlock {

    public let name: String
    public let size: CGFloat
    public let weight: String

    public init(name: String = "Serif", size: CGFloat = 16, weight: String = "normal") {
        self.name = name
        self.size = size
        self.weight = weight
    }

    public func toSwiftUI() -> Font {
        return Font.custom(name, size: size).weight(fontWeight(from: weight))
    }

    func serialize(_ serializer: Serializer) {
        serializer.add("name", name, "Serif").add("size", size, 16).add("weight", weight, "normal")
    }
    
    private func fontWeight(from: String) -> Font.Weight {
        // TODO: lighter and bolder are context-based, this is temporary.
        switch from {
        case "lighter":
			return .light
        case "normal":
			return .regular
        case "bold":
			return .bold
        case "bolder":
			return .black
        case "100":
			return .ultraLight
        case "200":
			return .thin
        case "300":
			return .light
        case "400":
			return .regular
        case "500":
			return .medium
        case "600":
			return .semibold
        case "700":
			return .bold
        case "800":
			return .heavy
        case "900":
			return .black
        default:
			return .regular
        }
    }

}


