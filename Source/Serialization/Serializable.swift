//
//  Serializable.swift
//  SVGView
//
//  Created by Yuriy Strot on 18.01.2021.
//

import Foundation

protocol SerializableAtom {

    func serialize() -> String

}

protocol SerializableOption {

    func isDefault() -> Bool

    func serialize() -> String

}

protocol SerializableBlock {

    func serialize(_ serializer: Serializer)

}

protocol SerializableElement: SerializableBlock {

    var id: String? { get }

    var typeName: String { get }

}

protocol SerializableEnum: SerializableOption, RawRepresentable, CaseIterable, Equatable where Self.RawValue == String {

}

extension SerializableEnum {

    func isDefault() -> Bool {
        return self == type(of: self).allCases.first
    }

    func serialize() -> String {
        return rawValue
    }

}
