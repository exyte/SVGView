//
//  SVGLinker.swift
//  SVGView
//
//  Created by Yuri Strot on 27.05.2022.
//

import Foundation

public class SVGLinker {

    public static let none = SVGLinker()

    public static func base(url: URL) -> SVGLinker {
        return SVGURLLinker(url: url)
    }

    public static func relative(to svgURL: URL) -> SVGLinker {
        return SVGURLLinker(url: svgURL.deletingLastPathComponent())
    }

    public func load(src: String) throws -> Data? {
        return nil
    }

}

class SVGURLLinker: SVGLinker {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    public override func load(src: String) throws -> Data? {
        let url = url.appendingPathComponent(src)
        return try Data(contentsOf: url)
    }
}
