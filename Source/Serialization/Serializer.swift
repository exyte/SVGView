//
//  Serializer.swift
//  SVGView
//
//  Created by Yuriy Strot on 17.01.2021.
//

import Foundation
import CoreGraphics

class Serializer {

    static func serialize(_ serializable: SerializableBlock) -> String {
        return serialize(serializable, level: 0) + "\n"
    }

    private static func serialize(_ serializable: SerializableBlock, level: Int) -> String {
        let serializer = Serializer(level: level)
        var prefix = ""
        if let element = serializable as? SerializableElement {
            prefix = element.typeName + " "
            serializer.add("id", element.id)
        }
        serializable.serialize(serializer)
        return prefix + serializer.toString()
    }

    private let level: Int

    private var blocks = [String]()
    private var text = ""
    private var complex = false

    private init(level: Int) {
        self.level = level
    }

    @discardableResult func add<S: SerializableAtom>(_ key: String, _ value: S?) -> Serializer {
        if let val = value {
            add(key: key, block: val.serialize())
        }
        return self
    }

    @discardableResult func add<S>(_ key: String, _ value: S, _ defVal: S) -> Serializer where S: SerializableAtom, S: Equatable {
        if (value != defVal) {
            add(key: key, block: value.serialize())
        }
        return self
    }

    @discardableResult public func add<S: SerializableOption>(_ key: String, _ value: S) -> Serializer {
        if !value.isDefault() {
            add(key: key, block: "\"\(value.serialize())\"")
        }
        return self
    }

    @discardableResult public func add(_ key: String, _ value: SerializableBlock?) -> Serializer {
        if let val = value {
            makeComplex()
            add(key: key, block: Serializer.serialize(val, level: level + 1))
        }
        return self
    }

    @discardableResult public func add(_ key: String, _ values: [SerializableBlock]) -> Serializer {
        if !values.isEmpty {
            makeComplex()
            add(key: key, block: "[")
            var isFirst = true
            for value in values {
                if isFirst {
                    isFirst = false
                } else {
                    text += ","
                }
                text += "\n" + indent(level + 2) + Serializer.serialize(value, level: level + 2)
            }
            text += "\n\(indent(level + 1))]"
        }
        return self
    }

    private func toString() -> String {
        if complex {
            return "{" + text + "\n" + indent(level) + "}"
        }
        let length = blocks.reduce(0) { $0 + $1.count }
        if length > 60 {
            let ind = indent(level + 1)
            return "{\n\(ind)\(blocks.joined(separator: ",\n\(ind)"))\n\(indent(level))}"
        }
        return "{ " + blocks.joined(separator: ", ") + " }"
    }

    private func makeComplex() {
        if !complex {
            complex = true
            for block in blocks {
                add(block: block)
            }
            blocks = []
        }
    }

    private func add(key: String, block: String) {
        add(block: "\(key): \(block)")
    }

    private func add(block: String) {
        if complex {
            add(string: block)
        } else {
            blocks.append(block)
        }
    }

    private func add(string: String) {
        if !text.isEmpty {
            text += ","
        }
        text += "\n" + indent(level + 1) + string
    }

    private func indent(_ indent: Int) -> String {
        return String(repeating: "\t", count: indent)
    }

}
