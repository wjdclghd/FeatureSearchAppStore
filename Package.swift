// swift-tools-version: 6.0
//
//  Package.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/15/26.
//

import PackageDescription

let package = Package(
    name: "FeatureSearchAppStore",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureSearchAppStore",
            targets: ["FeatureSearchAppStore"]
        )
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "FeatureSearchAppStore",
            dependencies: [
                
            ],
            path: "Sources/FeatureSearchAppStore",
            linkerSettings: [
                
            ]
        ),
        .testTarget(
            name: "FeatureSearchAppStoreTests",
            dependencies: [
                "FeatureSearchAppStore",
                
            ],
            path: "Tests/FeatureSearchAppStoreTests",
            linkerSettings: [
                
            ]
        )
    ]
)
