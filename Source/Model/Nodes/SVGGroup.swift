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

    override public func getNode(byId id: String) -> SVGNode? {
        if let node = super.getNode(byId: id) {
            return node
        }
        for node in contents {
            if let node = node.getNode(byId: id) {
                return node
            }
        }
        return .none
    }

    override func serialize(_ serializer: Serializer) {
        super.serialize(serializer)
        serializer.add("contents", contents)
    }

    public func contentView() -> some View {
        SVGGroupView(model: self)
    }
}

struct SVGGroupView: View {

    @ObservedObject var model: SVGGroup

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

