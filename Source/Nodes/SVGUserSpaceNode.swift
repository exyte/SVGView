//
//  SVGUserSpaceNode.swift
//  Pods
//
//  Created by Alisa Mylnikova on 14/10/2020.
//

import SwiftUI

public class SVGUserSpaceNode: SVGNode {

    public enum UserSpace: String, SerializableEnum {

        case objectBoundingBox
        case userSpaceOnUse

    }

    public let node: SVGNode
    public let userSpace: UserSpace

    public init(node: SVGNode, userSpace: UserSpace) {
        self.node = node
        self.userSpace = userSpace
    }

    override public func toSwiftUI() -> AnyView {
        if userSpace == .userSpaceOnUse {
            return node.toSwiftUI()
        }

        fatalError("Pass absolute node parameter for objectBoundingBox to work properly")
    }

    public func toSwiftUI(absoluteNode: SVGNode) -> AnyView {
        if userSpace == .userSpaceOnUse {
            return node.toSwiftUI()
        }

        let respective = SVGHelper.transformForNodeInRespectiveCoords(respective: node, absolute: absoluteNode)
        return AnyView(
            node.toSwiftUI().transformEffect(respective)
        )
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("userSpace", userSpace)
        super.serialize(serializer)
    }

}
