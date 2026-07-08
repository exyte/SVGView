//
//  SVGCacheModel.swift
//  SVGView
//
//  Created by Michael Gavrilenko on 10.08.2025.
//

import Foundation

final class SVGCache {
    static let shared = SVGCache()

    private let cache = NSCache<NSURL, SVGNode>()

    private init() {}

    func getNode(for url: URL) -> SVGNode? {
        let key = url as NSURL

        if let cachedNode = cache.object(forKey: key) {
            return cachedNode
        }

        print("SVGCache: Parsing and caching new node for \(url.lastPathComponent)")
        guard let newNode = SVGParser.parse(contentsOf: url) else {
            return nil
        }

        cache.setObject(newNode, forKey: key)

        return newNode
    }
}
