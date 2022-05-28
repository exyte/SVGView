//
//  DOMParser.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/08/2020.
//

import SwiftUI

public struct DOMParser {

    static public func parse(contentsOf url: URL, logger: SVGLogger = .console) -> XMLElement? {
        parse(XMLParser(contentsOf: url), logger: logger)
    }

    @available(*, deprecated, message: "Use parse(contentsOf:) function instead")
    static public func parse(fileURL: URL, logger: SVGLogger = .console) -> XMLElement? {
        parse(XMLParser(contentsOf: fileURL), logger: logger)
    }

    static public func parse(data: Data, logger: SVGLogger = .console) -> XMLElement? {
        parse(XMLParser(data: data), logger: logger)
    }

    static public func parse(string: String?, using encoding: String.Encoding = .utf8, logger: SVGLogger = .console) -> XMLElement? {
        guard let data = string?.data(using: encoding) else { return nil }
        return parse(XMLParser(data: data), logger: logger)
    }

    static public func parse(stream: InputStream, logger: SVGLogger = .console) -> XMLElement? {
        parse(XMLParser(stream: stream), logger: logger)
    }

    static private func parse(_ parser: XMLParser?, logger: SVGLogger) -> XMLElement? {
        let delegate = XMLDelegate(logger: logger)
        parser?.delegate = delegate
        parser?.parse()
        return delegate.root
    }
}

class XMLDelegate: NSObject, XMLParserDelegate {

    let logger: SVGLogger
    var root: XMLElement?
    var stack = [XMLElement]()

    init(logger: SVGLogger) {
        self.logger = logger
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let element = XMLElement(name: elementName, attributes: attributeDict)
        stack.last?.contents.append(element)
        stack.append(element)
        if root == nil {
            root = element
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        _ = stack.popLast()
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let element = stack.last {
            if let textNode = element.contents.last as? XMLText {
                textNode.text.append(string)
            } else {
                element.contents.append(XMLText(text: string))
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        logger.log(error: parseError)
    }

}
