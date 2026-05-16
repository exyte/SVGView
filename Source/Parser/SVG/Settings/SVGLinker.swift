//
//  SVGLinker.swift
//  SVGView
//
//  Created by Yuri Strot on 27.05.2022.
//

import Foundation

public class SVGLinker {

    public static let none = SVGLinker()

    public static func base(url: URL) -> SVGLinker {
        return SVGURLLinker(url: url)
    }

    public static func relative(to svgURL: URL) -> SVGLinker {
        return SVGURLLinker(url: svgURL.deletingLastPathComponent())
    }

    public func load(src: String) throws -> Data? {
        return nil
    }

}

class SVGURLLinker: SVGLinker {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    public override func load(src: String) throws -> Data? {
        let src = src.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !src.isEmpty else { return nil }

        guard URLComponents(string: src)?.scheme == nil else {
            return nil
        }

        let resolvedURL: URL
        if url.isFileURL {
            resolvedURL = URL(fileURLWithPath: src, relativeTo: url).standardizedFileURL
            guard url.contains(resolvedFileURL: resolvedURL) else {
                return nil
            }
        } else if let url = URL(string: src, relativeTo: url)?.absoluteURL {
            resolvedURL = url
        } else {
            return nil
        }

        return try Data(contentsOf: resolvedURL)
    }
}

private extension URL {
    func contains(resolvedFileURL: URL) -> Bool {
        guard isFileURL, resolvedFileURL.isFileURL else { return false }

        let basePath = standardizedFileURL.resolvingSymlinksInPath().path
        let resolvedPath = resolvedFileURL.standardizedFileURL.resolvingSymlinksInPath().path
        let baseDirectoryPath = basePath.hasSuffix("/") ? basePath : basePath + "/"

        return resolvedPath == basePath || resolvedPath.hasPrefix(baseDirectoryPath)
    }
}
