// swift-tools-version:5.7

import PackageDescription

let package = Package(
	name: "SVGView",
	platforms: [
		.macOS(.v11),
        .iOS(.v14),
        .tvOS(.v16),
        .watchOS(.v7)
    ],
    products: [
    	.library(
    		name: "SVGView", 
    		targets: ["SVGView"]
    	)
    ],
    targets: [
    	.target(
    		name: "SVGView",
            path: "Source",
            exclude: ["Info.plist"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
