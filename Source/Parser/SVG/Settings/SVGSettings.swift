//
//  SVGSettings.swift
//  SVGView
//
//  Created by Yuri Strot on 29.05.2022.
//

import Foundation
import CoreGraphics

public struct SVGSettings {

    public static let `default` = SVGSettings()

    public let linker: SVGLinker?
    public let logger: SVGLogger
    public let dpi: CGFloat

    public init(linker: SVGLinker? = nil, logger: SVGLogger = .console, dpi: CGFloat = 90) {
        self.linker = linker
        self.logger = logger
        self.dpi = dpi
    }

    public init(base: URL, logger: SVGLogger = .console, dpi: CGFloat = 90) {
        self.init(linker: .base(url: base), logger: logger, dpi: dpi)
    }

    public init(relativeTo svgURL: URL, logger: SVGLogger = .console, dpi: CGFloat = 90) {
        self.init(linker: .relative(to: svgURL), logger: logger, dpi: dpi)
    }

    func linkIfNeeded(to svgURL: URL) -> SVGSettings {
        if linker == nil {
            return SVGSettings(relativeTo: svgURL, logger: logger, dpi: dpi)
        }
        return self
    }

}
