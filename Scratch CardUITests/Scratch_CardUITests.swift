import XCTest

final class Scratch_CardUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testCardPresentationFlow() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["UNSCRATCHED"].exists)
        app.buttons["scratchButton"].tap()
        XCTAssertTrue(app.staticTexts["Scratch your card"].exists)

        app.buttons["revealButton"].tap()
        XCTAssertTrue(app.staticTexts["YOUR UNIQUE CODE"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["scratchCode"].label, "SC-4829-7316")

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["SCRATCHED"].exists)
        app.buttons["activationButton"].tap()
        XCTAssertTrue(app.staticTexts["Activate your card"].waitForExistence(timeout: 5))
        app.buttons["activateCardButton"].tap()
        XCTAssertTrue(app.staticTexts["Your card is already activated"].waitForExistence(timeout: 4))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts["cardStatus"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testGIVENActivationFailsWHENErrorAlertIsShownTHENActivationSheetRemainsPresented() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments.append("-ui-test-activation-failure")
        app.launch()

        app.buttons["scratchButton"].tap()
        app.buttons["revealButton"].tap()
        XCTAssertTrue(app.staticTexts["YOUR UNIQUE CODE"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["activationButton"].tap()
        XCTAssertTrue(app.staticTexts["Activate your card"].waitForExistence(timeout: 5))
        app.buttons["activateCardButton"].tap()

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["activateCardButton"].exists)
    }

    @MainActor
    func testGIVENRevealInProgressWHENBackIsTappedTHENScratchingIsCancelled() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments.append("-ui-test-pending-reveal")
        app.launch()

        app.buttons["scratchButton"].tap()
        app.buttons["revealButton"].tap()
        XCTAssertEqual(app.staticTexts["scratchCode"].label, "Revealing…")

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["UNSCRATCHED"].waitForExistence(timeout: 3))

        app.buttons["scratchButton"].tap()
        XCTAssertEqual(app.staticTexts["scratchCode"].label, "A little mystery")
        XCTAssertTrue(app.buttons["revealButton"].isEnabled)
    }
}
