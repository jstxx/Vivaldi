//
//  Package.swift
//  
//
//  Created by Justin SL on 8/14/25.
//

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VivaldiModels",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "VivaldiModels", targets: ["VivaldiModels"])
    ],
    dependencies: [
        // keep empty for URLSession-only code
    ],
    targets: [
        .target(
            name: "VivaldiModels",
            dependencies: []),
        .testTarget(
            name: "VivaldiModelsTests",
            dependencies: ["VivaldiModels"])
    ]
)
