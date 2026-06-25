#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGNode: SerializableElement {

#if os(WASI) || os(Linux) || os(Android)
    public var transform: CGAffineTransform = CGAffineTransform.identity
    public var opaque: Bool
    public var opacity: Double
    public var clip: SVGNode?
    public var mask: SVGNode?
    public var id: String?
    public var markerStart: String?
    public var markerMid: String?
    public var markerEnd: String?
#else
    @Published public var transform: CGAffineTransform = CGAffineTransform.identity
    @Published public var opaque: Bool
    @Published public var opacity: Double
    @Published public var clip: SVGNode?
    @Published public var mask: SVGNode?
    @Published public var id: String?
    @Published public var markerStart: String?
    @Published public var markerMid: String?
    @Published public var markerEnd: String?
#endif


    public init(transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGNode? = nil, mask: SVGNode? = nil, id: String? = nil, markerStart: String? = nil, markerMid: String? = nil, markerEnd: String? = nil) {
        self.transform = transform
        self.opaque = opaque
        self.opacity = opacity
        self.clip = clip
        self.mask = mask
        self.id = id
        self.markerStart = markerStart
        self.markerMid = markerMid
        self.markerEnd = markerEnd
    }

    public func bounds() -> CGRect {
        let frame = frame()
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    public func frame() -> CGRect {
        fatalError()
    }

    public func getNode(byId id: String) -> SVGNode? {
        return self.id == id ? self : .none
    }

    #if canImport(SwiftUI)
    var gestures = [AnyGesture<()>]()
    public func onTapGesture(_ count: Int = 1, tapClosure: @escaping ()->()) {
        let newGesture = TapGesture(count: count).onEnded {
            tapClosure()
        }
        gestures.append(AnyGesture(newGesture.map { _ in () }))
    }

    public func addGesture<T: Gesture>(_ newGesture: T) {
        gestures.append(AnyGesture(newGesture.map { _ in () }))
    }

    public func removeAllGestures() {
        gestures.removeAll()
    }
    #endif

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

#if canImport(SwiftUI)
extension SVGNode {
    @ViewBuilder
    public func toSwiftUI() -> some View {
        switch self {
        case let model as SVGViewport:
            SVGViewportView(model: model)
        case let model as SVGGroup:
            model.contentView()
        case let model as SVGRect:
            model.contentView()
        case let model as SVGText:
            model.contentView()
        case let model as SVGDataImage:
            model.contentView()
        case let model as SVGURLImage:
            model.contentView()
        case let model as SVGEllipse:
            model.contentView()
        case let model as SVGLine:
            model.contentView()
        case let model as SVGPolyline:
            model.contentView()
        case let model as SVGPath:
            model.contentView()
        case let model as SVGCircle:
            model.contentView()
        case let model as SVGUserSpaceNode:
            model.contentView()
        case let model as SVGPolygon:
            model.contentView()
        case is SVGImage:
            fatalError("Base SVGImage is not convertable to SwiftUI")
        case is SVGShape:
            fatalError("Base shape SVGShape is not convertable to SwiftUI")
        default:
            fatalError("Base SVGNode is not convertable to SwiftUI")
        }
    }
}
#endif
