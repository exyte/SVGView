//
//  SVGColor.swift
//  SVGView
//
//  Created by Yuriy Strot on 19.01.2021.
//

import SwiftUI

public class SVGColor: SVGPaint {

    public static let black = SVGColor(0)
    public static let clear = SVGColor(0).opacity(0)

    public static func by(name: String) -> SVGColor? {
        if let hex = SVGColors.hex(of: name.lowercased()) {
            return SVGColor(hex)
        }
        return .none
    }

    public let value: Int

    public init(_ value: Int = 0) {
        self.value = value
    }

    public convenience init(r: Int, g: Int, b: Int, t: Int = 0) {
        let x = (t & 0xff) << 24
        let y = (r & 0xff) << 16
        let z = (g & 0xff) << 8
        let q = b & 0xff
        self.init(x | y | z | q)
    }

    public convenience init(r: Int, g: Int, b: Int, opacity: Double) {
        self.init(r: r, g: g, b: b, t: Int((( 1 - opacity) * 255)))
    }

    public convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(Int(rgbValue))
    }

    override func serialize(key: String, serializer: Serializer) {
        var prefix = ""
        let transparency = t
        if transparency != 0 {
            prefix = "\(Int(round(Double(255 - transparency) * 100 / 255)))% "
        }

        let hex = ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff)
        if let text = SVGColors.text(of: hex) {
            serializer.add(key, "\(prefix)\(text)")
        } else {
            serializer.add(key, "\(prefix)#\(String(format: "%02X%02X%02X", r, g, b))")
        }
    }

    public func toSwiftUI() -> Color {
        return Color(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff).opacity(opacity)
    }

    func apply<S>(view: S, model: SVGShape? = nil) -> some View where S : View {
        view.foregroundColor(toSwiftUI())
    }

    public var r: Int {
        return (value >> 16) & 0xff
    }

    public var g: Int {
        return (value >> 8) & 0xff
    }

    public var b: Int {
        return value & 0xff
    }

    var a: Int {
        return 255 - t
    }

    var t: Int {
        return (value >> 24) & 0xff
    }

    var opacity: Double {
        return Double(a) / 255
    }

    public override func opacity(_ opacity: Double) -> SVGColor {
        return SVGColor(r: r, g: g, b: b, opacity: opacity)
    }

}

public func == (lhs: SVGColor, rhs: SVGColor) -> Bool {
    return lhs.value == rhs.value
}

extension Color: SerializableAtom {

    static func by(name: String) -> Color? {
        if let hex = SVGColors.hex(of: name.lowercased()) {
            return Color(rgbValue: hex)
        }
        return .none
    }

    func serialize() -> String {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return "\"n/a\""
        }
        let r = Int(round(components[0] * 255))
        let g = Int(round(components[1] * 255))
        let b = Int(round(components[2] * 255))
        var prefix = ""
        if components.count >= 4 {
            let a = Float(components[3])
            if a != 1 {
                prefix = "\(Int(round(a * 100)))% "
            }
        }

        let hex = ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff)
        if let text = SVGColors.text(of: hex) {
            return "\"\(prefix)\(text)\""
        }

        return "\"\(prefix)#\(String(format: "%02X%02X%02X", r, g, b))\""
    }

    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(rgbValue: Int(rgbValue))
    }

    init(rgbValue: Int) {
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }

}

class SVGColors {

    static func hex(of text: String) -> Int? {
        return instance.hexByText[text]
    }

    static func text(of hex: Int) -> String? {
        return instance.textByHex[hex]
    }

    private static let instance = SVGColors()

    private var hexByText = [String:Int]()
    private var textByHex = [Int:String]()

    init() {
        add(text: "white", hex: 0xffffff)
        add(text: "silver", hex: 0xc0c0c0)
        add(text: "gray", hex: 0x808080)
        add(text: "black", hex: 0)
        add(text: "red", hex: 0xff0000)
        add(text: "maroon", hex: 0x800000)
        add(text: "yellow", hex: 0xffff00)
        add(text: "olive", hex: 0x808000)
        add(text: "lime", hex: 0x00ff00)
        add(text: "green", hex: 0x008000)
        add(text: "aqua", hex: 0x00ffff)
        add(text: "teal", hex: 0x008080)
        add(text: "blue", hex: 0x0000ff)
        add(text: "navy", hex: 0x000080)
        add(text: "fuchsia", hex: 0xff00ff)
        add(text: "purple", hex: 0x800080)

        add(text: "aliceblue", hex: 0xf0f8ff)
        add(text: "antiquewhite", hex: 0xfaebd7)
        add(text: "aquamarine", hex: 0x7fffd4)
        add(text: "azure", hex: 0xf0ffff)
        add(text: "beige", hex: 0xf5f5dc)
        add(text: "bisque", hex: 0xffe4c4)
        add(text: "blanchedalmond", hex: 0xffebcd)
        add(text: "blueviolet", hex: 0x8a2be2)
        add(text: "brown", hex: 0xa52a2a)
        add(text: "burlywood", hex: 0xdeb887)
        add(text: "cadetblue", hex: 0x5f9ea0)
        add(text: "chartreuse", hex: 0x7fff00)
        add(text: "chocolate", hex: 0xd2691e)
        add(text: "coral", hex: 0xff7f50)
        add(text: "cornflowerblue", hex: 0x6495ed)
        add(text: "cornsilk", hex: 0xfff8dc)
        add(text: "crimson", hex: 0xdc143c)
        // cyan equals to aqua
        add(text: "cyan", hex: 0x00ffff, isKey: false)
        add(text: "darkblue", hex: 0x00008b)
        add(text: "darkcyan", hex: 0x008b8b)
        add(text: "darkgoldenrod", hex: 0xb8860b)
        add(text: "darkgray", hex: 0xa9a9a9)
        add(text: "darkgreen", hex: 0x006400)
        add(text: "darkkhaki", hex: 0xbdb76b)
        add(text: "darkmagenta", hex: 0x8b008b)
        add(text: "darkolivegreen", hex: 0x556b2f)
        add(text: "darkorange", hex: 0xff8c00)
        add(text: "darkorchid", hex: 0x9932cc)
        add(text: "darkred", hex: 0x8b0000)
        add(text: "darksalmon", hex: 0xe9967a)
        add(text: "darkseagreen", hex: 0x8fbc8f)
        add(text: "darkslateblue", hex: 0x483d8b)
        add(text: "darkslategray", hex: 0x2f4f4f)
        add(text: "darkturquoise", hex: 0x00ced1)
        add(text: "darkviolet", hex: 0x9400d3)
        add(text: "deeppink", hex: 0xff1493)
        add(text: "deepskyblue", hex: 0x00bfff)
        add(text: "dimgray", hex: 0x696969)
        add(text: "dodgerblue", hex: 0x1e90ff)
        add(text: "firebrick", hex: 0xb22222)
        add(text: "floralwhite", hex: 0xfffaf0)
        add(text: "forestgreen", hex: 0x228b22)
        add(text: "gainsboro", hex: 0xdcdcdc)
        add(text: "ghostwhite", hex: 0xf8f8ff)
        add(text: "gold", hex: 0xffd700)
        add(text: "goldenrod", hex: 0xdaa520)
        add(text: "greenyellow", hex: 0xadff2f)
        add(text: "honeydew", hex: 0xf0fff0)
        add(text: "hotpink", hex: 0xff69b4)
        add(text: "indianred", hex: 0xcd5c5c)
        add(text: "indigo", hex: 0x4b0082)
        add(text: "ivory", hex: 0xfffff0)
        add(text: "khaki", hex: 0xf0e68c)
        add(text: "lavender", hex: 0xe6e6fa)
        add(text: "lavenderblush", hex: 0xfff0f5)
        add(text: "lawngreen", hex: 0x7cfc00)
        add(text: "lemonchiffon", hex: 0xfffacd)
        add(text: "lightblue", hex: 0xadd8e6)
        add(text: "lightcoral", hex: 0xf08080)
        add(text: "lightcyan", hex: 0xe0ffff)
        add(text: "lightgoldenrodyellow", hex: 0xfafad2)
        add(text: "lightgray", hex: 0xd3d3d3)
        add(text: "lightgreen", hex: 0x90ee90)
        add(text: "lightpink", hex: 0xffb6c1)
        add(text: "lightsalmon", hex: 0xffa07a)
        add(text: "lightseagreen", hex: 0x20b2aa)
        add(text: "lightskyblue", hex: 0x87cefa)
        add(text: "lightslategray", hex: 0x778899)
        add(text: "lightsteelblue", hex: 0xb0c4de)
        add(text: "lightyellow", hex: 0xffffe0)
        add(text: "limegreen", hex: 0x32cd32)
        add(text: "linen", hex: 0xfaf0e6)
        add(text: "mediumaquamarine", hex: 0x66cdaa)
        add(text: "mediumblue", hex: 0x0000cd)
        add(text: "mediumorchid", hex: 0xba55d3)
        add(text: "mediumpurple", hex: 0x9370db)
        add(text: "mediumseagreen", hex: 0x3cb371)
        add(text: "mediumslateblue", hex: 0x7b68ee)
        add(text: "mediumspringgreen", hex: 0x00fa9a)
        add(text: "mediumturquoise", hex: 0x48d1cc)
        add(text: "mediumvioletred", hex: 0xc71585)
        add(text: "midnightblue", hex: 0x191970)
        add(text: "mintcream", hex: 0xf5fffa)
        add(text: "mistyrose", hex: 0xffe4e1)
        add(text: "moccasin", hex: 0xffe4b5)
        add(text: "navajowhite", hex: 0xffdead)
        add(text: "oldlace", hex: 0xfdf5e6)
        add(text: "olivedrab", hex: 0x6b8e23)
        add(text: "orange", hex: 0xffa500)
        add(text: "orangered", hex: 0xff4500)
        add(text: "orchid", hex: 0xda70d6)
        add(text: "palegoldenrod", hex: 0xeee8aa)
        add(text: "palegreen", hex: 0x98fb98)
        add(text: "paleturquoise", hex: 0xafeeee)
        add(text: "palevioletred", hex: 0xdb7093)
        add(text: "papayawhip", hex: 0xffefd5)
        add(text: "peachpuff", hex: 0xffdab9)
        add(text: "peru", hex: 0xcd853f)
        add(text: "pink", hex: 0xffc0cb)
        add(text: "plum", hex: 0xdda0dd)
        add(text: "powderblue", hex: 0xb0e0e6)
        add(text: "rebeccapurple", hex: 0x663399)
        add(text: "rosybrown", hex: 0xbc8f8f)
        add(text: "royalblue", hex: 0x4169e1)
        add(text: "saddlebrown", hex: 0x8b4513)
        add(text: "salmon", hex: 0xfa8072)
        add(text: "sandybrown", hex: 0xf4a460)
        add(text: "seagreen", hex: 0x2e8b57)
        add(text: "seashell", hex: 0xfff5ee)
        add(text: "sienna", hex: 0xa0522d)
        add(text: "skyblue", hex: 0x87ceeb)
        add(text: "slateblue", hex: 0x6a5acd)
        add(text: "slategray", hex: 0x708090)
        add(text: "snow", hex: 0xfffafa)
        add(text: "springgreen", hex: 0x00ff7f)
        add(text: "steelblue", hex: 0x4682b4)
        add(text: "tan", hex: 0xd2b48c)
        add(text: "thistle", hex: 0xd8bfd8)
        add(text: "tomato", hex: 0xff6347)
        add(text: "turquoise", hex: 0x40e0d0)
        add(text: "violet", hex: 0xee82ee)
        add(text: "wheat", hex: 0xf5deb3)
        add(text: "whitesmoke", hex: 0xf5f5f5)
        add(text: "yellowgreen", hex: 0x9acd32)

#if os(OSX)
        add(text: "appworkspace", hex: 0xaaaaaa, isKey: false)
        add(text: "activeborder", hex: 0x992a6ccd, isKey: false)
        add(text: "activecaption", hex: 0x242424, isKey: false)
        add(text: "background", hex: 0x6363ce, isKey: false)
        add(text: "buttonface", hex: 0xc0c0c0, isKey: false)
        add(text: "buttonhighlight", hex: 0xffffff, isKey: false)
        add(text: "buttonshadow", hex: 0x8d8d8d, isKey: false)
        add(text: "captiontext", hex: 0x000000, isKey: false)
        add(text: "highlighttext", hex: 0x000000, isKey: false)
        add(text: "menu", hex: 0xf6f6f6, isKey: false)
        add(text: "menutext", hex: 0xffffff, isKey: false)
        add(text: "threedface", hex: 0xc0c0c0, isKey: false)
        add(text: "threeddarkshadow", hex: 0x000000, isKey: false)
        add(text: "threedlightshadow", hex: 0xffffff, isKey: false)
        add(text: "window", hex: 0xececec, isKey: false)
        add(text: "windowframe", hex: 0xaaaaaa, isKey: false)
        add(text: "windowtext", hex: 0x242424, isKey: false)
#else
        add(text: "appworkspace", hex: 0xffffff, isKey: false)
        add(text: "activeborder", hex: 0xffffff, isKey: false)
        add(text: "activecaption", hex: 0xcccccc, isKey: false)
        add(text: "background", hex: 0x6363ce, isKey: false)
        add(text: "buttonface", hex: 0xc0c0c0, isKey: false)
        add(text: "buttonhighlight", hex: 0xcccccc, isKey: false)
        add(text: "buttonshadow", hex: 0x888888, isKey: false)
        add(text: "captiontext", hex: 0x000000, isKey: false)
        add(text: "highlighttext", hex: 0x000000, isKey: false)
        add(text: "menu", hex: 0xc0c0c0, isKey: false)
        add(text: "menutext", hex: 0x000000, isKey: false)
        add(text: "threedface", hex: 0xc0c0c0, isKey: false)
        add(text: "threeddarkshadow", hex: 0x666666, isKey: false)
        add(text: "threedlightshadow", hex: 0xc0c0c0, isKey: false)
        add(text: "window", hex: 0xffffff, isKey: false)
        add(text: "windowframe", hex: 0xcccccc, isKey: false)
        add(text: "windowtext", hex: 0x000000, isKey: false)
#endif
    }

    private func add(text: String, hex: Int, isKey: Bool = true) {
        hexByText[text] = hex
        if isKey {
            textByHex[hex] = text
        }
    }

}
