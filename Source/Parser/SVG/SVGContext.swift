//
//  SVGContext.swift
//  SVGView
//
//  Created by Yuri Strot on 26.05.2022.
//

import CoreGraphics

protocol SVGContext {

    var logger: SVGLogger { get }
    var linker: SVGLinker { get }
    var screen: SVGScreen { get }
    var index: SVGIndex { get }
    var defaultFontSize: CGFloat { get }

    var fontSize: CGFloat { get }
    var root: SVGRootContext { get }

    func create(for: XMLElement) -> SVGNodeContext?
}

extension SVGContext {

    func log(message: String) {
        logger.log(message: message)
    }

    public func log(error: Error) {
        logger.log(error: error)
    }

}

struct SVGRootContext: SVGContext {

    let logger: SVGLogger
    let linker: SVGLinker
    let screen: SVGScreen
    let index: SVGIndex
    let defaultFontSize: CGFloat

    func create(for element: XMLElement) -> SVGNodeContext? {
        return SVGNodeContext(root: self, element: element)
    }

    var root: SVGRootContext {
        return self
    }

    var fontSize: CGFloat {
        defaultFontSize
    }

}

class SVGNodeContext: SVGContext {

    let root: SVGRootContext
    let element: XMLElement
    let useIds: [String]

    let styles: [String:String]
    let properties: [String:String]

    init(root: SVGRootContext, element: XMLElement, parentStyles: [String:String] = [:], useIds: [String] = []) {
        self.root = Self.replaceRoot(element: element, context: root)
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
                log(message: "<use> recursion detected!")
                return nil
            }
            useIds = newUseIds(useId: useId)
        }

        return SVGNodeContext(root: root, element: child, parentStyles: styles, useIds: useIds)
    }

    var fontSize: CGFloat {
        return value(.fontSize)
    }

    func value<Value>(_ attribute: SVGDefaultAttribute<Value>) -> Value {
        if let value = optional(attribute) {
            return value
        }
        return attribute.defaultValue(context: self)
    }

    func optional<Value>(_ attribute: SVGAttribute<Value>) -> Value? {
        if let string = attribute.isInherited ? styles[attribute.name] : properties[attribute.name] {
            return attribute.parse(string: string, context: self)
        }
        return nil
    }

    func style(_ name: String) -> String? {
        return styles[name]
    }

    func property(_ name: String) -> String? {
        return properties[name]
    }

    private static func replaceRoot(element: XMLElement, context: SVGContext) -> SVGRootContext {
        if element.name == "svg" {
            if let viewBox = SVGViewportParser.parseViewBox(element.attributes, context: context) {
                let screen = SVGScreen(ppi: context.screen.ppi, width: viewBox.width, height: viewBox.height)
                return SVGRootContext(logger: context.logger, linker: context.linker, screen: screen, index: context.index, defaultFontSize: context.defaultFontSize)
            }
        }
        return context.root
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

    var linker: SVGLinker { root.linker }

    var screen: SVGScreen { root.screen }

    var index: SVGIndex { root.index }

    var defaultFontSize: CGFloat { root.defaultFontSize }

}
