//
//  randomMessageTests.swift
//  randomMessageTests
//
//  Created by Paulo Silva on 24/09/2018.
//  Copyright © 2018 Paulo Silva. All rights reserved.
//

import XCTest
@testable import randomMessage

class randomMessageTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGivenRandomMessageWhenSubjectABCAndSchedulerFilterAMThenItWorks() {
        self.randomMessageTestingForSubject("abc", withSchedulerFilter: "am")

        self.randomMessageTestingForSubject("ABC", withSchedulerFilter: "AM")
    }

    func testGivenRandomMessageWhenSubjectABCAndSchedulerFilterPMThenItWorks() {
        self.randomMessageTestingForSubject("abc", withSchedulerFilter: "pm")

        self.randomMessageTestingForSubject("ABC", withSchedulerFilter: "PM")
    }

    func testGivenRandomMessageWhenSubjectCBAAndSchedulerFilterAMThenItWorks() {
        self.randomMessageTestingForSubject("cba", withSchedulerFilter: "am")

        self.randomMessageTestingForSubject("CBA", withSchedulerFilter: "AM")
    }

    func testGivenRandomMessageWhenSubjectCBAAndSchedulerFilterPMThenItWorks() {
        self.randomMessageTestingForSubject("cba", withSchedulerFilter: "pm")

        self.randomMessageTestingForSubject("CBA", withSchedulerFilter: "PM")
    }
    
    func testGivenRandomMessageWhenSubjectXPTOAndSchedulerFilterAMAndPMThenItFailsNoSubject() {
        self.randomMessageTestingForSubject("XPTO", withSchedulerFilter: "AM")

        self.randomMessageTestingForSubject("XPTO", withSchedulerFilter: "PM")
    }
    
    func testGivenRandomMessageWhenSubjectABCAndSchedulerFilterMAAndMPThenItFailsNoSchedulerFilter() {
        self.randomMessageTestingForSubject("ABC", withSchedulerFilter: "MA")
        
        self.randomMessageTestingForSubject("ABC", withSchedulerFilter: "MP")
    }
    
    private func randomMessageTestingForSubject(_ subject: String, withSchedulerFilter schedulerFilter: String) {
        let rndMessage = randomMessage()
        var messageItems = [String: Int]()

        print("-- ------------------------------------------------------------------------------------")
        print(" Get 1000 Random Messages for the Following Criteria: Subject: \(subject), Schedule: \(schedulerFilter)")
        print("-- ------------------------------------------------------------------------------------")

        for _ in 1...1000 {
            let localizedKey = rndMessage.getMessageForSubject(subject, schedulerFilter: schedulerFilter)
            if messageItems[localizedKey] != nil {
                messageItems[localizedKey] = messageItems[localizedKey]! + 1
            } else {
                messageItems[localizedKey] = 1
            }
        }

        for (key, value) in messageItems {
            print("the Message: \(key), was selected to be shown: \(value) times.")
            
            if schedulerFilter.lowercased() == "pm" {
                // Check if exists the message8, message9, message14 and message14 has pm scheduler
                XCTAssertNotEqual(key, "message8", "Unexpected AM only message: \(key).")
                XCTAssertNotEqual(key, "message9", "Unexpected AM only message: \(key).")
                XCTAssertNotEqual(key, "message14", "Unexpected AM only message: \(key).")
                XCTAssertNotEqual(key, "message15", "Unexpected AM only message: \(key).")
            }
        }
        
        print("-- ------------------------------------------------------------------------------------")
    }
}
