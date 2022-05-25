//
//  SVGParserImages.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 10/06/2021.
//

import SwiftUI

extension SVGHelper {

    static func parseImage(_ attributes: [String: String], style: [String: String]) -> SVGImage? {
        guard let src = attributes["xlink:href"] else {
            return .none
        }
        let x = parseCGFloat(attributes, "x")
        let y = parseCGFloat(attributes, "y")
        let width = parseCGFloat(attributes, "width")
        let height = parseCGFloat(attributes, "height")

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

        // file URL
        return SVGURLImage(x: x, y: y, width: width, height: height, src: src)
    }
}
