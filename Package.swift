// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PaulaCochinaAPI",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "7.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "PaulaCochinaAPI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MongoKitten", package: "MongoKitten"),
                .product(name: "JWT", package: "jwt")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "RecetasAPITests",
            dependencies: ["PaulaCochinaAPI"]
        )
    ]
)
