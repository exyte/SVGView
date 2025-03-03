// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "SVGView",
	platforms: [
		.macOS(.v11),
        .iOS(.v14),
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
        ),
        .testTarget(
            name: "SVGViewTests",
            dependencies: ["SVGView"],
            path: "SVGViewTests",
            resources: [.copy("w3c")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
