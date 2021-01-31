//
//  DOMParser.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 20/08/2020.
//

import SwiftUI

public struct DOMParser {

    static public func parse(fileURL: URL) -> XMLElement {
        let parser = XMLParser(contentsOf: fileURL)
        let delegate = XMLDelegate()
        parser?.delegate = delegate
        parser?.parse()
        return delegate.root!
    }
}

class XMLDelegate: NSObject, XMLParserDelegate {

    var root: XMLElement?
    var stack = [XMLElement]()

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
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
        // TODO: need to handle errors correctly
        print(parseError.localizedDescription)
    }

}
