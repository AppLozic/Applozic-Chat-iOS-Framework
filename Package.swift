// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Applozic",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "ApplozicCore",
            targets: ["ApplozicCore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ApplozicCore",
            dependencies: [],
            path: "ApplozicCore",
            exclude: ["Info.plist",
                      "MQTT/MQTTClient-Prefix.pch"],
            resources: [
                .copy("push/TSMessagesDefaultDesign.json")
            ],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("account"),
                .headerSearchPath("applozickit"),
                .headerSearchPath("channel"),
                .headerSearchPath("commons"),
                .headerSearchPath("conversation"),
                .headerSearchPath("database"),
                .headerSearchPath("JWT"),
                .headerSearchPath("message"),
                .headerSearchPath("MQTT"),
                .headerSearchPath("networkcommunication"),
                .headerSearchPath("notification"),
                .headerSearchPath("prefrence"),
                .headerSearchPath("push"),
                .headerSearchPath("sync"),
                .headerSearchPath("user"),
                .headerSearchPath("utilities")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("UIKit", .when(platforms: [.iOS]))
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
