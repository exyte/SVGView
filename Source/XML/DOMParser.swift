//
//  DOMParser.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/08/2020.
//

import SwiftUI

public struct DOMParser {

    static var whitespaceRegex = try! NSRegularExpression(pattern: "\\s+", options: NSRegularExpression.Options.caseInsensitive)

    static public func parse(fileURL: URL) -> XMLElement? {
        commonParse(XMLParser(contentsOf: fileURL))
    }

    static public func parse(data: Data) -> XMLElement? {
        commonParse(XMLParser(data: data))
    }

    static public func parse(string: String?) -> XMLElement? {
        guard let data = string?.data(using: .utf8) else {
            return nil
        }
        return commonParse(XMLParser(data: data))
    }

    static public func parse(stream: InputStream) -> XMLElement? {
        commonParse(XMLParser(stream: stream))
    }

    static private func commonParse(_ parser: XMLParser?) -> XMLElement? {
        let delegate = XMLDelegate()
        parser?.delegate = delegate
        parser?.parse()
        return delegate.root
    }
}

class XMLDelegate: NSObject, XMLParserDelegate {

    var root: XMLElement?
    var stack = [XMLElement]()

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
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines).processingWhitespaces()
            if let textNode = element.contents.last as? XMLText {
                textNode.text.append(trimmed)
            } else {
                element.contents.append(XMLText(text: trimmed))
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // TODO: need to handle errors correctly
        print(parseError.localizedDescription)
    }

}

extension String {

    fileprivate func processingWhitespaces() -> String {
        let range = NSMakeRange(0, self.count)
        let modString = DOMParser.whitespaceRegex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: " ")
        return modString
    }
}
