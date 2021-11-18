import SwiftUI

class SVGViewport: SVGGroup {

    @Published public var width: SVGLength {
        willSet {
            self.objectWillChange.send()
        }
    }

    @Published public var height: SVGLength {
        willSet {
            self.objectWillChange.send()
        }
    }

    @Published public var viewBox: CGRect? {
        willSet {
            self.objectWillChange.send()
        }
    }

    @Published public var preserveAspectRatio: SVGPreserveAspectRatio {
        willSet {
            self.objectWillChange.send()
        }
    }

    public init(width: SVGLength, height: SVGLength, viewBox: CGRect? = .none, preserveAspectRatio: SVGPreserveAspectRatio, contents: [SVGNode] = []) {
        self.width = width
        self.height = height
        self.viewBox = viewBox
        self.preserveAspectRatio = preserveAspectRatio
        super.init(contents: contents)
    }

    override public func bounds() -> CGRect {
        let size = computeSize(parent: .zero)
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("width", width.toString(), "100%")
        serializer.add("height", height.toString(), "100%")
        serializer.add("viewBox", viewBox)
        serializer.add("scaling", preserveAspectRatio.scaling)
        serializer.add("xAlign", preserveAspectRatio.xAlign)
        serializer.add("yAlign", preserveAspectRatio.yAlign)
        super.serialize(serializer)
    }

    private func computeSize(parent: CGSize) -> CGSize {
        return CGSize(width: width.toPixels(total: parent.width),
                      height: height.toPixels(total: parent.height))
    }

    func layout(node: SVGNode, in size: CGSize) {
        let svgSizeInPixels = computeSize(parent: size)

        if let viewBox = self.viewBox {
            node.clip = SVGRect(viewBox)
        }
        let viewBox = self.viewBox ?? CGRect(x: 0, y: 0, width: svgSizeInPixels.width, height: svgSizeInPixels.height)
        if let slice = preserveAspectRatio.slice(size: svgSizeInPixels, into: viewBox) {
            node.clip = slice
        }

        node.transform = preserveAspectRatio.layout(size: viewBox.size, into: svgSizeInPixels)

        // move to (0, 0)
        node.transform = node.transform.translatedBy(x: -viewBox.minX, y: -viewBox.minY)
    }

}
