//
//  SVGCachedView.swift
//  SVGView
//
//  Created by Michael Gavrilenko on 10.08.2025.
//

import SwiftUI

public struct CachedSVGView: View {
    public let svg: SVGNode?

    public init(contentsOf url: URL) {
        svg = SVGCache.shared.getNode(for: url)
    }

    @available(*, deprecated, message: "Use (contentsOf:) initializer instead")
    public init(fileURL: URL) {
        svg = SVGCache.shared.getNode(for: fileURL)
    }

    public init(data: Data) {
        svg = SVGParser.parse(data: data)
    }

    public init(string: String) {
        svg = SVGParser.parse(string: string)
    }

    public init(stream: InputStream) {
        svg = SVGParser.parse(stream: stream)
    }

    public init(xml: XMLElement) {
        svg = SVGParser.parse(xml: xml)
    }

    public init(svg: SVGNode) {
        self.svg = svg
    }

    public func getNode(byId id: String) -> SVGNode? {
        svg?.getNode(byId: id)
    }

    public var body: some View {
        svg?.toSwiftUI()
    }
}
