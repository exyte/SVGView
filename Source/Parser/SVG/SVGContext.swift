//
//  SVGContext.swift
//  SVGView
//
//  Created by Yuri Strot on 26.05.2022.
//

import CoreGraphics

protocol SVGContext {
    var logger: SVGLogger  { get }
    var linker: SVGLinker? { get }
    var screen: SVGScreen  { get }
    var index: SVGIndex    { get }

    func create(for: XMLElement) -> SVGNodeContext?
}

struct SVGRootContext: SVGContext {

    let logger: SVGLogger
    let linker: SVGLinker?
    let screen: SVGScreen
    let index: SVGIndex

    func create(for element: XMLElement) -> SVGNodeContext? {
        return SVGNodeContext(root: self, element: element)
    }

}

class SVGNodeContext: SVGContext {

    let root: SVGContext
    let element: XMLElement
    let useIds: [String]

    let styles: [String:String]
    let properties: [String:String]

    init(root: SVGContext, element: XMLElement, parentStyles: [String:String] = [:], useIds: [String] = []) {
        self.root = root
        self.element = element
        self.useIds = useIds
        self.properties = element.attributes.filter { !SVGConstants.availableStyleAttributes.contains($0.key) }

        let styleDict = SVGParser.getStyleAttributes(xml: element, index: root.index)
        self.styles = Self.mergeStyles(element: styleDict, parent: parentStyles)
    }

    func create(for child: XMLElement) -> SVGNodeContext? {
        var useIds = self.useIds
        if child.name == "use", let useId = child.attributes["xlink:href"]?.replacingOccurrences(of: "#", with: "") {
            if useIds.contains(useId) {
                logger.log(message: "<use> recursion detected!")
                return nil
            }
            useIds = newUseIds(useId: useId)
        }

        return SVGNodeContext(root: root, element: child, parentStyles: styles, useIds: useIds)
    }

    func style(_ name: String) -> String? {
        return styles[name]
    }

    func property(_ name: String) -> String? {
        return properties[name]
    }

    private func newUseIds(useId: String? = nil) -> [String] {
        if let useId = useId {
            return useIds + [useId]
        }
        return useIds
    }

    private static func mergeStyles(element: [String:String], parent: [String:String]) -> [String:String] {
        var result = parent
        for (key, value) in element {
            result[key] = value
        }
        return result
    }

    var logger: SVGLogger { root.logger }

    var linker: SVGLinker? { root.linker }

    var screen: SVGScreen { root.screen }

    var index: SVGIndex { root.index }
}
