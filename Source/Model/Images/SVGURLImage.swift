//
//  SVGURLImage.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 22/09/2021.
//

#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
#endif

public class SVGURLImage: SVGImage {

    public let src: String
    public let data: Data?

    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, src: String, data: Data?) {
        self.src = src
        self.data = data
        super.init(x: x, y: y, width: width, height: height)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("src", src)
        super.serialize(serializer)
    }

    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGUrlImageView(model: self)
    }
    #endif
}

#if canImport(SwiftUI)
extension SVGURLImage: ObservableObject {}
struct SVGUrlImageView: View {

    @ObservedObject var model: SVGURLImage

#if os(OSX)
    @ViewBuilder
    private var image: Image? {
        if let data = model.data, let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
        }
    }
#else
    @ViewBuilder
    private var image: Image? {
        if let data = model.data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
        }
    }
#endif

    public var body: some View {
        image
            .frame(width: model.width, height: model.height)
            .position(x: model.x, y: model.y)
            .offset(x: model.width/2, y: model.height/2)
            .applyNodeAttributes(model: model)
    }
}
#endif

