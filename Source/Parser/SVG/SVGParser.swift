//
//  SVGView.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/07/2020.
//

import SwiftUI

public struct SVGParser {

    static public func parse(contentsOf url: URL, settings: SVGSettings = .default) -> SVGNode? {
        let xml = DOMParser.parse(contentsOf: url, logger: settings.logger)
        return parse(xml: xml, settings: settings.linkIfNeeded(to: url))
    }

    static public func parse(data: Data, settings: SVGSettings = .default) -> SVGNode? {
        let xml = DOMParser.parse(data: data, logger: settings.logger)
        return parse(xml: xml, settings: settings)
    }

    static public func parse(string: String, settings: SVGSettings = .default) -> SVGNode? {
        let xml = DOMParser.parse(string: string, logger: settings.logger)
        return parse(xml: xml, settings: settings)
    }

    static public func parse(stream: InputStream, settings: SVGSettings = .default) -> SVGNode? {
        let xml = DOMParser.parse(stream: stream, logger: settings.logger)
        return parse(xml: xml, settings: settings)
    }

    static public func parse(xml: XMLElement?, settings: SVGSettings = .default) -> SVGNode? {
        guard let xml = xml else { return nil }

        return parse(element: xml, parentContext: SVGRootContext(
            logger: settings.logger,
            linker: settings.linker,
            screen: SVGScreen.main(ppi: settings.ppi),
            index: SVGIndex(element: xml),
            defaultFontSize: settings.fontSize))
    }

    @available(*, deprecated, message: "Use parse(contentsOf:) function instead")
    static public func parse(fileURL: URL) -> SVGNode? {
        return parse(contentsOf: fileURL)
    }

    private static func parse(element: XMLElement, parentContext: SVGContext) -> SVGNode? {
        guard let context = parentContext.create(for: element) else { return nil }
        return parse(context: context)
    }

    private static let parsers: [String:SVGElementParser] = [
        "svg": SVGViewportParser(),
        "g": SVGGroupParser(),
        "use": SVGUseParser(),
        "text": SVGTextParser(),
        "image": SVGImageParser(),
        "rect": SVGRectParser(),
        "circle": SVGCircleParser(),
        "ellipse": SVGEllipseParser(),
        "line": SVGLineParser(),
        "polygon": SVGPolygonParser(),
        "polyline": SVGPolylineParser(),
        "path": SVGPathParser(),
    ]

    private static func parse(context: SVGNodeContext) -> SVGNode? {
        return parsers[context.element.name]?.parse(context: context) {
            parse(element: $0, parentContext: context)
        }
    }

    static func getStyleAttributes(xml: XMLElement, index: SVGIndex) -> [String: String] {
        var styleDict = xml.attributes.filter { SVGConstants.availableStyleAttributes.contains($0.key) }
            .filter { $0.value != "inherit" }

        for (att, val) in index.cssStyle(for: xml) {
            if styleDict.index(forKey: att) == nil {
                styleDict.updateValue(val, forKey: att)
            }
        }

        if let cssStyle = xml.attributes["style"] {
            let styleParts = cssStyle.replacingOccurrences(of: " ", with: "").components(separatedBy: ";")
            styleParts.forEach { styleAttribute in
                let currentStyle = styleAttribute.components(separatedBy: ":")
                if currentStyle.count == 2 {
                    styleDict.updateValue(currentStyle[1], forKey: currentStyle[0])
                }
            }
        }

        // TODO: it's a temporary solution. Need to create a correct style merging mechanics
        if styleDict["fill"] == "currentColor", let color = styleDict["color"] {
            styleDict["fill"] = color
        }

        return styleDict
    }

}
