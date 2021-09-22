//
//  SVGUrlImage.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 22/09/2021.
//

import SwiftUI

public class SVGUrlImage: SVGImage, ObservableObject {

    @Published public var src: String

    public var data: Data? {
        if let url = SVGParser.fileURL?.deletingLastPathComponent().appendingPathComponent(src) {
            return try? Data(contentsOf: url)
        }
        return nil
    }

    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, src: String) {
        self.src = src
        super.init(x: x, y: y, width: width, height: height)
    }

    override public func toSwiftUI() -> AnyView {
        AnyView(SVGUrlImageView(model: self))
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("url", src)
        super.serialize(serializer)
    }
}

struct SVGUrlImageView: View {

    @ObservedObject var model: SVGUrlImage

    public var body: some View {

        var result = AnyView(EmptyView())

        #if os(OSX)
        if let data = model.data, let nsImage = NSImage(data: data) {
            result = AnyView(Image(nsImage: nsImage)
                                .resizable())
        }
        #else
        if let data = model.data, let uiImage = UIImage(data: data) {
            result = AnyView(Image(uiImage: uiImage)
                                .resizable())
        }
        #endif

        return result
            .frame(width: model.width, height: model.height)
            .position(x: model.x, y: model.y)
            .offset(x: model.width/2, y: model.height/2)
            .applyNodeAttributes(model: model)
    }
}

