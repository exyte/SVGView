//
//  SVGPaint.swift
//  SVGView
//
//  Created by Yuriy Strot on 19.01.2021.
//

import Foundation
import SwiftUI

public enum SVGPaint: SerializableAtom {

    case color(Color)

    func serialize() -> String {
        switch self {
        case .color(let color):
            return color.serialize()
        }
    }

}

extension View {

    func apply(paint: SVGPaint?) -> some View {
        if let p = paint {
            switch p {
            case .color(let color):
                return self.foregroundColor(color)
            }
        }
        return self.foregroundColor(Color.clear)
    }

}
