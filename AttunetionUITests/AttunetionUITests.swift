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

    #if os(iOS) || os(visionOS)
    @MainActor
    func testManualCreationPersists() throws {
        let app = XCUIApplication()
        app.launch()
        if app.buttons["Skip"].firstMatch.waitForExistence(timeout: 3) {
            app.buttons["Skip"].firstMatch.tap()
        }
        let create = app.buttons["New Intention"].firstMatch
        XCTAssertTrue(create.waitForExistence(timeout: 15), app.debugDescription)
        create.tap()
        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 10), app.debugDescription)
        editor.tap()
        let intention = "Take time to listen"
        editor.typeText(intention)
        app.buttons["Save"].tap()
        app.terminate()
        app.launch()
        let saved = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", intention)
        ).firstMatch
        XCTAssertTrue(saved.waitForExistence(timeout: 15), app.debugDescription)
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = "Saved intention"
        image.lifetime = .keepAlways
        add(image)
    }
    #endif

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
