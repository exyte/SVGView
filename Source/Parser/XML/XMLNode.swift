import SwiftUI

public protocol XMLNode {
}

public class XMLElement: XMLNode {

    public let name: String
    public var contents: [XMLNode] = []
    public var attributes: [String: String]

    public init(name: String, attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }
}

public class XMLText: XMLNode {

    public var text: String

    public init(text: String) {
        self.text = text
    }
}

