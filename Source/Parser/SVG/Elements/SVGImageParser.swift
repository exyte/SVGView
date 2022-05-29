//
//  SVGImageParser.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import SwiftUI

class SVGImageParser: SVGBaseElementParser {
    override func doParse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        guard let src = context.property("xlink:href") else { return nil }
        let x = SVGHelper.parseCGFloat(context.properties, "x")
        let y = SVGHelper.parseCGFloat(context.properties, "y")
        let width = SVGHelper.parseCGFloat(context.properties, "width")
        let height = SVGHelper.parseCGFloat(context.properties, "height")

        // Base64 image
        let decodableFormat = ["image/png", "image/jpg", "image/svg+xml"]
        for format in decodableFormat {
            let prefix = "data:\(format);base64,"
            if src.hasPrefix(prefix) {
                let src = String(src.suffix(from: prefix.endIndex))
                if let decodedData = Data(base64Encoded: src, options: .ignoreUnknownCharacters) {
                    return SVGDataImage(x: x, y: y, width: width, height: height, data: decodedData)
                }
            }
        }

        do {
            if let data = try context.linker.load(src: src) {
                return SVGURLImage(x: x, y: y, width: width, height: height, src: src, data: data)
            }
            context.log(message: "Couldn't find image `\(src)`")
        } catch {
            context.log(error: error)
        }
        return SVGURLImage(x: x, y: y, width: width, height: height, src: src, data: nil)
    }

}
