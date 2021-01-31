import SwiftUI

class StyleStack {

    var array: [[String : String]] = []

    func pushStyle(_ style: [String : String]) {
        array.append(style)
    }

    func popStyle() {
        let _ = array.removeLast()
    }

    func currentStyle() -> [String : String] {
        var result: [String : String] = [:]
        for attribute in SVGConstants.availableStyleAttributes {
            for style in array.reversed() {
                if style.contains(where: {
                    $0.key == attribute
                }) {
                    result[attribute] = style[attribute]
                    break
                }
            }
        }
        return result
    }
}

