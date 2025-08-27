//
//  Package.swift
//  
//
//  Created by Justin SL on 8/14/25.
//

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VivaldiDesignSystem",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "VivaldiDesignSystem", targets: ["VivaldiDesignSystem"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "VivaldiDesignSystem",
            dependencies: [],
            resources: [
                .process("Resources")
            ])
    ]
)
