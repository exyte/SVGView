//
//  SVGPaint.swift
//  SVGView
//
//  Created by Yuriy Strot on 19.01.2021.
//

import Foundation
import SwiftUI

public class SVGPaint {

    func serialize(key: String, serializer: Serializer) {
        
    }

    func apply<S>(view: S) -> AnyView where S : View {
        return AnyView(view)
    }

    public func opacity(_ opacity: Double) -> SVGPaint {
        return self
    }

}

extension View {

    func apply(paint: SVGPaint?) -> some View {
        if let p = paint {
            return AnyView(p.apply(view: self))
        }
        return AnyView(self.foregroundColor(.clear))
    }

}
