//
//  iOSEmprevoTests.swift
//  iOSEmprevoTests
//
//  Created by Chaithat Sukra on 11/08/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import XCTest
@testable import iOSEmprevo

class iOSEmprevoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGettingRate() {
        let expect = expectation(description: "server timeout")
        let manager: HTTPSessionManager = HTTPSessionManager();
        manager.requestGET("api/information/company") { (aObjectEvent) in
            XCTAssertTrue(true)
        }
        waitForExpectations(timeout: 1000000) { error in
            XCTAssertTrue(false)
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //this must be set before using waitForExpe...
        let expect = expectation(description: "server timeout")

//        let bl: ShiftBL = ShiftBL()
//        bl.requestListOfShift("-37.801092800000006",
//                              "144.89747079999998",
//                              "20") { (aObjectEvent: ObjectEvent) in
//                                XCTAssertTrue(true)
//        }
        let manager: HTTPSessionManager = HTTPSessionManager();
        manager.requestPOST("api/information/ratecard",
                            [
                                "Type": "Rate Card x",
                                "Rate1": "14",
                                "Rate2": "13",
                                "Rate3": "12",
                                "Rate4": "11",
                                "Id": "5741031244955648",
                                "Fn": "Update",
                            ]) { aObjectResult in
                                XCTAssertTrue(true)
        }
        waitForExpectations(timeout: 1000000) { error in
            
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
