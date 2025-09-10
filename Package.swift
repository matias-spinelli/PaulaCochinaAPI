// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RecetasAPI",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "7.0.0")
    ],
    targets: [
        .executableTarget(
            name: "RecetasAPI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MongoKitten", package: "MongoKitten"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "RecetasAPITests",
            dependencies: ["RecetasAPI"]
        )
    ]
)
