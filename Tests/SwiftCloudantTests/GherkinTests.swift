//
//  GherkinTests.swift
//  SwiftCloudant
//
//  Created by tomblench on 08/02/2017.
//
//

import Foundation

import XCTest
import XCTest_Gherkin

class testAThingThatNeedsTesting: XCTestCase {
    func testBasicSteps() {
        Given("A situation that I want to start at")
        When("I do a thing")
        And("I do another thing")
        Then("This value should be 100")
        And("This condition should be met as well")
    }
}

class SomeStepDefinitions : StepDefiner {
    override func defineSteps() {
        step("A situation that I want to start at") {
            print("situation");
        }

        step("I do.* thing") {
            print("do thing");
        }

        
        step("This value should be ([0-9]*)") { (matches: [String]) in
            let expectedValue = matches.first!
                XCTAssertEqual(expectedValue, "100")
        }
        step("This condition") {
            print("condition");
        }

    
    }
}
