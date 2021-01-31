import SwiftUI

public class SVGGroup: SVGNode, ObservableObject {

    @Published public var contents: [SVGNode] = []

    public init(contents: [SVGNode], transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGUserSpaceNode? = nil, mask: SVGNode? = nil) {
        super.init(transform: transform, opaque: opaque, opacity: opacity, clip: clip, mask: mask)
        self.contents = contents
    }

    override public func bounds() -> CGRect {
        contents.map { $0.bounds() }.reduce(contents.first?.bounds() ?? CGRect.zero) { $0.union($1) }
    }

    override public func toSwiftUI() -> AnyView {
        return AnyView(SVGGroupView(model: self))
    }

    override public func nodeById(_ id: String) -> SVGNode? {
        if let node = super.nodeById(id) {
            return node
        }
        for node in contents {
            if let node = node.nodeById(id) {
                return node
            }
        }
        return .none
    }

    override func serialize(_ serializer: Serializer) {
        super.serialize(serializer)
        serializer.add("contents", contents)
    }

}

struct SVGGroupView: View {

    @ObservedObject var model: SVGGroup

    public var body: some View {
        ZStack {
            ForEach(0..<model.contents.count) { i in
                if i <= model.contents.count - 1 {
                    model.contents[i].toSwiftUI()
                }
            }
        }
        .compositingGroup() // so that all the following attributes are applied to the group as a whole
        .applyNodeAttributes(model: model)
    }
}

