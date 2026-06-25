//
//  SVGDataImage.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 10/06/2021.
//

#if os(WASI) || os(Linux) || os(Android)
import Foundation
#else
import SwiftUI
import Combine
#endif

public class SVGDataImage: SVGImage {
    #if os(WASI) || os(Linux) || os(Android)           
    public var data: Data
    #else
    @Published public var data: Data
    #endif

    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, data: Data) {
        self.data = data
        super.init(x: x, y: y, width: width, height: height)
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("data", "\(data.base64EncodedString())")
        super.serialize(serializer)
    }

    #if canImport(SwiftUI)
    public func contentView() -> some View {
        SVGDataImageView(model: self)
    }
    #endif
}

#if canImport(SwiftUI)
extension SVGDataImage: ObservableObject {}
struct SVGDataImageView: View {

#if os(OSX)
    @ViewBuilder
    private var image: Image? {
        if let nsImage = NSImage(data: model.data) {
            Image(nsImage: nsImage)
        }
    }
#else
    @ViewBuilder
    private var image: Image? {
        if let uiImage = UIImage(data: model.data) {
            Image(uiImage: uiImage)
        }
    }
#endif

    @ObservedObject var model: SVGDataImage

    public var body: some View {
        image
            .frame(width: model.width, height: model.height)
            .position(x: model.x, y: model.y)
            .offset(x: model.width/2, y: model.height/2)
            .applyNodeAttributes(model: model)
    }
}
#endif
