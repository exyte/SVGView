//
//  UIExtensions.swift
//  SVGView
//
//  Created by Yuri Strot on 25.05.2022.
//

import SwiftUI

extension Shape {

    @ViewBuilder
    func applySVGStroke(stroke: SVGStroke?, eoFill: Bool = false) -> some View {
        if let stroke = stroke {
            if let linear = stroke.fill as? SVGLinearGradient {
                GeometryReader { geometry in
                    apllyFillStyle(eoFill: eoFill)
                        .overlay(self.stroke(linear.toSwiftUI(rect: geometry.frame(in: .local)), style: stroke.toSwiftUI()))
                }
            } else if let radial = stroke.fill as? SVGRadialGradient {
                GeometryReader { geometry in
                    apllyFillStyle(eoFill: eoFill)
                        .overlay(self.stroke(radial.toSwiftUI(rect: geometry.frame(in: .local)), style: stroke.toSwiftUI()))
                }
            } else if let color = stroke.fill as? SVGColor {
                apllyFillStyle(eoFill: eoFill)
                    .overlay(self.stroke(color.toSwiftUI(), style: stroke.toSwiftUI()))
            }
        } else {
            apllyFillStyle(eoFill: eoFill)
        }
    }

    @ViewBuilder
    func apllyFillStyle(eoFill: Bool = false) -> some View {
        if eoFill {
            self.fill(style: FillStyle(eoFill: true, antialiased: true))
        } else {
            self
        }
    }

}

extension View {

    func applyShapeAttributes(model: SVGShape) -> some View {
        apply(paint: model.fill, model: model).applyNodeAttributes(model: model)
    }

    func applyNodeAttributes(model: SVGNode) -> some View {
        self.opacity(model.opacity)
            .applyMask(mask: model.clip, absoluteNode: model)
            .transformEffect(model.transform)
            .applyIf(!model.gestures.isEmpty) {
                $0.gesture(makeOneGesture(model: model))
            }
    }

    func makeOneGesture(model: SVGNode) -> some Gesture {
        var result = model.gestures.first
        for gesture in model.gestures {
            result = AnyGesture(SimultaneousGesture(result, gesture).map { _ in () })
        }
        return result
    }

}

extension View {

    @ViewBuilder
    func applyMask(mask: SVGNode?, absoluteNode: SVGNode) -> some View {
        if let mask = mask as? SVGUserSpaceNode {
            if mask.userSpace == .userSpaceOnUse {
                self.mask(mask.node.toSwiftUI())
            } else {
                self.mask(mask.node.toSwiftUI().transformEffect(SVGHelper.transformForNodeInRespectiveCoords(respective: mask.node, absolute: absoluteNode)))
            }
        } else {
            self
        }
    }
}

extension View {

    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }

}
