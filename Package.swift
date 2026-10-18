// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TickTock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "TickTock", targets: ["TickTock"])
    ],
    targets: [
        .executableTarget(
            name: "TickTock",
            path: "TickTock/TickTock",
            exclude: [
                "Info.plist",
                "TickTock.entitlements",
                "Assets.xcassets"
            ]
        )
    ]
)

