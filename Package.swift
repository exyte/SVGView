// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "SVGView",
	platforms: [
		.macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6)
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
            path: "Source"
        )
    ],
    swiftLanguageVersions: [.v5]
)
