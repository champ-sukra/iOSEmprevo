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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //this must be set before using waitForExpe...
        let expect = expectation(description: "server timeout")

        let bl: ShiftBL = ShiftBL()
        bl.requestListOfShift("-37.801092800000006",
                              "144.89747079999998",
                              "10") { (aObjectEvent: ObjectEvent) in
                                print(aObjectEvent.result);
        }
//        let manager: HTTPSessionManager = HTTPSessionManager();
//        manager.requestPOST(["FromLat": "-37.801092800000006",
//                             "FromLon": "144.89747079999998",
//                             "Radius": "10"]) { aObjectResult in
//                                print(aObjectResult.message())
//        }
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
