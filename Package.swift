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
        .package(path: "../../Shared/AppDomain"),
        .package(path: "../../Core/UI/DesignSystem"),
        .package(path: "../../Core/UI/UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureSearchAppStore",
            dependencies: [
                "AppDomain",
                "DesignSystem",
                "UIComponents"
            ],
            path: "Sources/FeatureSearchAppStore",
            linkerSettings: [

            ]
        ),
        .testTarget(
            name: "FeatureSearchAppStoreTests",
            dependencies: [
                "FeatureSearchAppStore",
                "AppDomain",
                "UIComponents"
            ],
            path: "Tests/FeatureSearchAppStoreTests",
            linkerSettings: [

            ]
        )
    ]
)
