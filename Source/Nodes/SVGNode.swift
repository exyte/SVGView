import SwiftUI

public class SVGNode : SerializableElement {

    @Published public var transform: CGAffineTransform = CGAffineTransform.identity
    @Published public var opaque: Bool
    @Published public var opacity: Double
    @Published public var clip: SVGNode?
    @Published public var mask: SVGNode?
    //@Published public var effect: Effect?
    @Published public var id: String?

    public var onTap = {}

    public init(transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGNode? = nil, mask: SVGNode? = nil, id: String? = nil) {
        self.transform = transform
        self.opaque = opaque
        self.opacity = opacity
        self.clip = clip
        self.mask = mask
        self.id = id
    }

    public func bounds() -> CGRect {
        let frame = frame()
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    public func frame() -> CGRect {
        fatalError()
    }

    public func toSwiftUI() -> AnyView {
        fatalError()
    }

    public func nodeById(_ id: String) -> SVGNode? {
        return self.id == id ? self : .none
    }

    func serialize(_ serializer: Serializer) {
        if !transform.isIdentity {
            serializer.add("transform", transform)
        }
        serializer.add("opacity", opacity, 1)
        serializer.add("opaque", opaque, true)
        serializer.add("clip", clip).add("mask", mask)
    }

    var typeName: String {
        return String(describing: type(of: self))
    }

}

