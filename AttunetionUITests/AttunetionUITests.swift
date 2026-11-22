//
//  AttunetionUITests.swift
//  AttunetionUITests
//
//  Created by Nathan Fennel on 12/2/25.
//

import XCTest

final class AttunetionUITests: XCTestCase {

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
    func testOnboardingAndRelaunch() throws {
        let app = XCUIApplication()
        app.launch()
        #if os(watchOS)
        let sample = "Practice gratitude daily"
        let choice = app.buttons[sample]
        XCTAssertTrue(choice.waitForExistence(timeout: 15), app.debugDescription)
        choice.tap()
        XCTAssertTrue(app.staticTexts[sample].waitForExistence(timeout: 15), app.debugDescription)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts[sample].waitForExistence(timeout: 15), app.debugDescription)
        #elseif os(macOS)
        XCTAssertTrue(app.buttons["New Intention"].waitForExistence(timeout: 15))
        #else
        func advance(_ label: String) {
            let button = app.buttons[label].firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 15), app.debugDescription)
            for _ in 0..<6 where !button.isHittable {
                app.swipeUp()
            }
            XCTAssertTrue(button.isHittable, app.debugDescription)
            button.tap()
        }
        advance("Get Started")
        advance("Continue")
        #if os(iOS)
        advance("Continue")
        #endif
        advance("Maybe Later")
        advance("Get Started")
        XCTAssertTrue(app.buttons["New Intention"].waitForExistence(timeout: 15), app.debugDescription)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["New Intention"].waitForExistence(timeout: 15), app.debugDescription)
        #endif
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
