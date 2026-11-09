// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WinTools",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "WinTools", targets: ["WinTools"]),
        // Consumido pelo projeto Xcode gerado (project.yml) para os testes de UI (XCUITest).
        .library(name: "WinToolsCore", targets: ["WinToolsCore"]),
    ],
    targets: [
        // Lógica testável: catálogo, estado e aplicação das funcionalidades.
        .target(name: "WinToolsCore"),
        // App de barra de menus (SwiftUI). Só UI e composição; regra mora no Core.
        .executableTarget(name: "WinTools", dependencies: ["WinToolsCore"]),
        .testTarget(name: "WinToolsCoreTests", dependencies: ["WinToolsCore"]),
    ]
)
