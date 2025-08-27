//
//  Package.swift
//  
//
//  Created by Justin SL on 8/14/25.
//

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VivaldiPersistence",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "VivaldiPersistence", targets: ["VivaldiPersistence"])
    ],
    dependencies: [
        .package(path: "../VivaldiModels")
    ],
    targets: [
        .target(
            name: "VivaldiPersistence",
            dependencies: ["VivaldiModels"]),
        .testTarget(
            name: "VivaldiPersistenceTests",
            dependencies: ["VivaldiPersistence"])
    ]
)
