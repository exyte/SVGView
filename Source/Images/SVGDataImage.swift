//
//  SVGDataImage.swift
//  SVGView
//
//  Created by Alisa Mylnikova on 10/06/2021.
//

import SwiftUI

public class SVGDataImage: SVGImage, ObservableObject {

    @Published public var data: Data

    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, data: Data) {
        self.data = data
        super.init(x: x, y: y, width: width, height: height)
    }

    override public func toSwiftUI() -> AnyView {
        AnyView(SVGDataImageView(model: self))
    }

    override func serialize(_ serializer: Serializer) {
        serializer.add("data", "\(data.base64EncodedString())")
        super.serialize(serializer)
    }
}

struct SVGDataImageView: View {

    @ObservedObject var model: SVGDataImage

    public var body: some View {

        var result = AnyView(EmptyView())

        #if os(OSX)
        if let nsImage = NSImage(data: model.data) {
            result = AnyView(Image(nsImage: nsImage)
                                .resizable())
        }
        #else
        if let uiImage = UIImage(data: model.data) {
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
