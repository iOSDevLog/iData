//
//  apiTests.swift
//  iDataTests
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import XCTest
@testable import iData
@testable import Alamofire

class apiTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testSearch() {
        let expect =  self.expectation(description: "Search")
        
        let parameters: Parameters =
            [
                "app_id": "iOSDevLog",
                "access_token": "C3RoqraAz6nTJBhF",
                "keyword": "iOS",
                "sort_type": "1",
                "db": "SCDB",
                "start": "0",
                "advance": "0",
                ]
        Alamofire.request(kSearchUrl, method: .get, parameters: parameters).responsePaper { response in
            if let paper = response.result.value {
                print(paper)
                XCTAssert(paper.status == 1)
                XCTAssert((paper.data?.items?.count)! > 0)
                expect.fulfill()
            }
        }
        self.waitForExpectations(timeout: 10) { (e) in
            XCTAssert(e == nil, e.debugDescription)
        }
    }
    
    func testDocDetail() {
        let expect =  self.expectation(description: "DocDetail")
        
        let parameters: Parameters =
            [
                "app_id": "iOSDevLog",
                "access_token": "C3RoqraAz6nTJBhF",
                "filename": "JCYJ201405007",
                "dbcode": "CJFQ"
        ]
        Alamofire.request(kDocDetailUrl, method: .get, parameters: parameters).responseDocDetail { response in
            if let docDetail = response.result.value {
                expect.fulfill()
                print(docDetail)
            }
        }
        self.waitForExpectations(timeout: 10) { (e) in
            XCTAssert(e == nil, e.debugDescription)
        }
    }
    
    func testDUrl() {
        let expect =  self.expectation(description: "DUrl")
        
        let parameters: Parameters =
            [
                "app_id": "iOSDevLog",
                "access_token": "C3RoqraAz6nTJBhF",
                "filename": "JCYJ201405007",
                "filename_en": "zhFawRVNSpmVwEkZ59ESa5kYURFetVWVU9Sd5hEMWRleNhUVvF0Kqp0a2E3Vvt0QwhDe2Y0RzlFSYVUbzlkTiVDe6FmUx8CTWdURtdnavQHd6Z3cQxESU10VkZHOrtyLalUZ2syKtdjZYNnTXh0azI0VzwUREJGV",
                "title": "社会资本对跨组织信息系统吸收影响机理研究",
                "author": "",
                "tablename": "CJFD2014"
        ]
        Alamofire.request(kDUrl, method: .get, parameters: parameters).responseDURL { response in
            if let dUrl = response.result.value {
                expect.fulfill()
                print(dUrl)
            }
        }
        self.waitForExpectations(timeout: 10) { (e) in
            XCTAssert(e == nil, e.debugDescription)
        }
    }
}
