//
//  SVGView.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/08/2020.
//

import SwiftUI

public struct SVGView: View {

    public let svg: SVGNode?

    public init(contentsOf url: URL) {
        self.svg = SVGParser.parse(contentsOf: url)
    }

    @available(*, deprecated, message: "Use (contentsOf:) initializer instead")
    public init(fileURL: URL) {
        self.svg = SVGParser.parse(contentsOf: fileURL)
    }

    public init(data: Data) {
        self.svg = SVGParser.parse(data: data)
    }

    public init(string: String) {
        self.svg = SVGParser.parse(string: string)
    }

    public init(stream: InputStream) {
        self.svg = SVGParser.parse(stream: stream)
    }

    public init(xml: XMLElement) {
        self.svg = SVGParser.parse(xml: xml)
    }

    public init(svg: SVGNode) {
        self.svg = svg
    }

    public func getNode(byId id: String) -> SVGNode? {
        return svg?.getNode(byId: id)
    }

    public var body: some View {
        svg?.toSwiftUI()
    }

}
