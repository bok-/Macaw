// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Macaw",
    platforms: [ .macOS(.v10_11), .iOS(.v9) ],
    products: [
        .library(name: "Macaw", targets: ["Macaw"])
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.7.5")
    ],
    targets: [
        .target(name: "Macaw", dependencies: ["SWXMLHash"]),
        .testTarget(name: "MacawTests", dependencies: ["Macaw"])
    ]
)
