//
//  SVGElementParser.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import Foundation

protocol SVGElementParser {

    func parse(context: SVGNodeContext, delegate: @escaping (XMLElement) -> SVGNode?) -> SVGNode?

}

class SVGBaseElementParser: SVGElementParser {

    func parse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        guard let node = doParse(context: context, delegate: delegate) else { return nil }
        let transform = SVGHelper.parseTransform(context.properties["transform"] ?? "")
        node.transform = node.transform.concatenating(transform)
        node.opacity = SVGHelper.parseOpacity(context.properties, "opacity")

        if let clipId = SVGHelper.parseUse(context.properties["clip-path"]),
           let clipNode = context.index.element(by: clipId),
           let clip = delegate(clipNode) {
            node.clip = SVGUserSpaceNode(node: clip, userSpace: parse(userSpace: clipNode.attributes["clipPathUnits"]))
        }

        node.id = SVGHelper.parseId(context.properties)
        return node
    }

    /// should be overwritten by inheritor
    func doParse(context: SVGNodeContext, delegate: (XMLElement) -> SVGNode?) -> SVGNode? {
        return nil
    }

    private func parse(userSpace: String?) -> SVGUserSpaceNode.UserSpace {
        if let value = userSpace, let result = SVGUserSpaceNode.UserSpace(rawValue: value) {
            return result
        }
        return SVGUserSpaceNode.UserSpace.objectBoundingBox
    }

}
