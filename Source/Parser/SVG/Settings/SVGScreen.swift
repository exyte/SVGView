//
//  SVGScreen.swift
//  SVGView
//
//  Created by Yuri Strot on 27.05.2022.
//

import CoreGraphics

struct SVGScreen {

    static func main(ppi: Double) -> SVGScreen {
        // TODO: need to use UIScreen / NSScreen for this
        return SVGScreen(ppi: ppi, width: 100, height: 100)
    }

    let ppi: Double
    let width: Double
    let height: Double

}
