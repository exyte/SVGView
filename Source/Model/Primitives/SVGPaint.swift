//
//  SVGPaint.swift
//  SVGView
//
//  Created by Yuriy Strot on 19.01.2021.
//

#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
#endif

public class SVGPaint {

    func serialize(key: String, serializer: Serializer) {
        
    }

    public func opacity(_ opacity: Double) -> SVGPaint {
        return self
    }

}

#if canImport(SwiftUI)
extension View {

    @ViewBuilder
    func apply(paint: SVGPaint?, model: SVGShape? = nil) -> some View {
        if let p = paint {
            switch p {
            case let linearGradient as SVGLinearGradient:
                linearGradient.apply(view: self, model: model)
            case let radialGradient as SVGRadialGradient:
                radialGradient.apply(view: self, model: model)
            case let color as SVGColor:
                color.apply(view: self, model: model)
            default:
                fatalError("Base SVGPaint is not convertable to SwiftUI")
            }
        } else {
            self.foregroundColor(.clear)
        }
    }

}
#endif
