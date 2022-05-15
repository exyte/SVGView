//
//  SVGLength.swift
//  Pods
//
//  Created by Alisa Mylnikova on 13/10/2020.
//

import SwiftUI

enum SVGLength {

    case percent(CGFloat)
    case pixels(CGFloat)

    init(percent: CGFloat) {
        self = .percent(percent)
    }

    init(pixels: CGFloat) {
        self = .pixels(pixels)
    }

    var ideal: CGFloat? {
        switch self {
        case .percent(_):
            return nil
        case let .pixels(pixels):
            return pixels
        }
    }

    func toPixels(total: CGFloat) -> CGFloat {
        switch self {
        case let .percent(percent):
            return total * percent / 100.0
        case let .pixels(pixels):
            return pixels
        }
    }

    func toString() -> String {
        switch(self) {
        case let .percent(percent):
            return "\(percent.serialize())%"
        case let .pixels(pixels):
            return pixels.serialize()
        }
    }
}
