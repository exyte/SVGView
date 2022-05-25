//
//  SVGImage.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 03/06/2021.
//

import SwiftUI

public class SVGImage: SVGNode {

    @Published public var x: CGFloat
    @Published public var y: CGFloat
    @Published public var width: CGFloat
    @Published public var height: CGFloat

    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("x", x, 0).add("y", y, 0).add("width", width, 0).add("height", height, 0)
        super.serialize(serializer)
    }
}
