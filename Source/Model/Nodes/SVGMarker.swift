#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGMarker: SVGGroup {
    public enum Orient {
        case auto
        case autoStartReverse
        case angle(Float)

        public init(rawValue: String) {
            if rawValue == "auto" {
                self = .auto
            } else if rawValue == "auto-start-reverse" {
                self = .autoStartReverse
            } else if let angle = Float(rawValue) {
                self = .angle(angle)
            } else {
                self = .angle(0)
            }
        }

        public func toString() -> String {
            switch self {
            case .auto:
                return "auto"
            case .autoStartReverse:
                return "auto-start-reverse"
            case .angle(let f):
                return "\(f)"
            }
        }
    }

    public enum RefMagnitude {
        case left
        case center
        case right
        case coordinate(SVGLength)

        public func toString() -> String {
            switch self {
            case .left:
                return "left"
            case .center:
                return "center"
            case .right:
                return "right"
            case .coordinate(let f):
                return f.toString()
            }
        }
    }

    public enum MarkerUnits: String, SerializableEnum {
        case userSpaceOnUse
        case strokeWidth
    }

    #if os(WASI) || os(Linux) || os(Android)
    public var markerHeight: SVGLength
    public var markerUnits: MarkerUnits
    public var markerWidth: SVGLength
    public var orient: Orient
    public var preserveAspectRatio: SVGPreserveAspectRatio
    public var refX: RefMagnitude?
    public var refY: RefMagnitude?
    public var viewBox: CGRect?
    #else
    @Published public var markerHeight: SVGLength
    @Published public var markerUnits: MarkerUnits
    @Published public var markerWidth: SVGLength
    @Published public var orient: Orient
    @Published public var preserveAspectRatio: SVGPreserveAspectRatio
    @Published public var refX: RefMagnitude?
    @Published public var refY: RefMagnitude?
    @Published public var viewBox: CGRect?
    #endif

    public init(
        markerHeight: SVGLength,
        markerUnits: MarkerUnits,
        markerWidth: SVGLength,
        orient: Orient,
        preserveAspectRatio: SVGPreserveAspectRatio,
        refX: RefMagnitude?,
        refY: RefMagnitude?,
        viewBox: CGRect? = nil,
        contents: [SVGNode]
    ) {
        self.markerHeight = markerHeight
        self.markerUnits = markerUnits
        self.markerWidth = markerWidth
        self.orient = orient
        self.preserveAspectRatio = preserveAspectRatio
        self.refX = refX
        self.refY = refY
        self.viewBox = viewBox
        super.init(contents: contents)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("contents", contents)
        serializer.add("markerHeight", markerHeight.toString(), "100%")
        serializer.add("markerUnits", markerUnits)
        serializer.add("markerWidth", markerWidth.toString(), "100%")
        serializer.add("orient", orient.toString())

        // preserveAspectRatio, please refer to the implementation in SVGViewport
        serializer.add("scaling", preserveAspectRatio.scaling)
        serializer.add("xAlign", preserveAspectRatio.xAlign)
        serializer.add("yAlign", preserveAspectRatio.yAlign)

        if let refXStr = refX?.toString() {
            serializer.add("refX", refXStr)
        }
        if let refYStr = refY?.toString() {
            serializer.add("refY", refYStr)
        }

        serializer.add("viewBox", viewBox)

        super.serialize(serializer)

    }

    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGMarkerView(model: self)
    }
    #endif

    override var typeName: String {
        return String(describing: type(of: self))
    }

    func parseContents(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> [SVGNode] {
        return context.element.contents
            .compactMap { $0 as? XMLElement }
            .compactMap { delegate($0) }
    }
}

#if canImport(SwiftUI)
struct SVGMarkerView: View {

    @ObservedObject var model: SVGMarker

    public var body: some View {
        ZStack {
            ForEach(0..<model.contents.count, id: \.self) { i in
                if i <= model.contents.count - 1 {
                    model.contents[i].toSwiftUI()
                }
            }
        }
        .compositingGroup() // so that all the following attributes are applied to the group as a whole
        .applyNodeAttributes(model: model)
    }
}
#endif

