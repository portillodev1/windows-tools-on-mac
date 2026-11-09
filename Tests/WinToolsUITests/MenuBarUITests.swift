import XCTest

/// Testes ponta a ponta do menu: abrem o WinTools.app de verdade e o controlam como um usuário.
/// Identificadores: `AccessibilityID` em Sources/WinTools/MenuContentView.swift (mude os dois juntos).
@MainActor
final class MenuBarUITests: XCTestCase {
    private let featureIDs = ["clipboard-history", "terminal-windows", "finder-windows"]

    /// Abre o app em modo de teste (estado isolado) e clica no ícone da barra de menus.
    private func launchAndOpenMenu() -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        addTeardownBlock { @MainActor in app.terminate() }

        let statusItem = app.statusItems.firstMatch
        XCTAssertTrue(statusItem.waitForExistence(timeout: 10), "Ícone do WinTools não apareceu na barra de menus")
        statusItem.click()
        XCTAssertTrue(app.staticTexts["menu-title"].waitForExistence(timeout: 5), "Painel do menu não abriu")
        return app
    }

    func test_menu_whenOpened_listsAllRoadmapFeatures() {
        let app = launchAndOpenMenu()

        for id in featureIDs {
            XCTAssertTrue(app.descendants(matching: .any)["feature-\(id)"].exists, "Funcionalidade \(id) não listada")
        }
    }

    func test_menu_plannedFeatures_showComingSoonWithoutToggle() {
        let app = launchAndOpenMenu()

        for id in featureIDs {
            XCTAssertTrue(app.staticTexts["feature-\(id)-status"].exists, "\(id) deveria mostrar 'Em breve'")
            XCTAssertFalse(app.switches["feature-\(id)-toggle"].exists, "\(id) planejada não pode ter toggle")
        }
    }

    func test_quitButton_whenClicked_terminatesApp() {
        let app = launchAndOpenMenu()

        app.buttons["menu-quit"].click()

        XCTAssertTrue(app.wait(for: .notRunning, timeout: 5), "O app deveria encerrar ao clicar em Sair")
    }
}
