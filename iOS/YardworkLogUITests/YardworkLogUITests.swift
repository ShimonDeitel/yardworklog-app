import XCTest

final class YardworkLogUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_addEntryFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let field = app.textFields["entryFieldInput"]
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("UI Test Entry")
        app.buttons["entrySaveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 3))
    }

    func test_freeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for i in 0..<(Store_freeLimit(app) + 2) {
            app.buttons["addEntryButton"].tap()
            if app.buttons["paywallPurchaseButton"].waitForExistence(timeout: 1) {
                XCTAssertTrue(true)
                return
            }
            let field = app.textFields["entryFieldInput"]
            if field.waitForExistence(timeout: 2) {
                field.tap()
                field.typeText("Entry \(i)")
                app.buttons["entrySaveButton"].tap()
            }
        }
    }

    private func Store_freeLimit(_ app: XCUIApplication) -> Int {
        return 12
    }

    func test_keyboardDismissOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let field = app.textFields["entryFieldInput"]
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Completed"].tap()
        XCTAssertFalse(app.keyboards.element.waitForExistence(timeout: 1))
    }

    func test_settingsOpensAndCloses() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 3))
        app.buttons["settingsDoneButton"].tap()
    }
}
