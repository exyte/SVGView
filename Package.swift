// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "SVGView",
	platforms: [
		.macOS(.v11),
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
            path: "Source",
            exclude: ["Info.plist"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
