//
//  Package.swift
//  
//
//  Created by Justin SL on 8/14/25.
//

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VivaldiAPIClient",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "VivaldiAPIClient", targets: ["VivaldiAPIClient"])
    ],
    dependencies: [
        .package(path: "../VivaldiModels")
    ],
    targets: [
        .target(
            name: "VivaldiAPIClient",
            dependencies: ["VivaldiModels"]
        ),
        .testTarget(
            name: "VivaldiAPIClientTests",
            dependencies: ["VivaldiAPIClient"]
        )
    ]
)
