//
//  SVGView.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/08/2020.
//

import SwiftUI

public struct SVGView: View {

    private let svg: SVGNode

    public init(fileURL: URL) {
        let xml = DOMParser.parse(fileURL: fileURL)
        self.svg = SVGParser.parse(xml: xml, fileURL: fileURL)
    }

    public init(xml: XMLElement) {
        self.svg = SVGParser.parse(xml: xml)
    }

    public init(svg: SVGNode) {
        self.svg = svg
    }

    public var body: some View {
        svg.toSwiftUI()
    }

}
