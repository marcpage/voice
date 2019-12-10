//
//  Prophet_s_VoiceTests.swift
//  Prophet's VoiceTests
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import XCTest
@testable import Prophet_s_Voice

class Prophet_s_VoiceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConferenceTalkLoadingPerformance() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "general_conference_talks", withExtension: "json") else {
            XCTFail()
            return
        }
        self.measure {
            do {
                let talks = try ConferenceTalk.load(from: path)
                XCTAssert(talks.count > 0)
            } catch {
                XCTFail()
            }
        }
    }
    
    func testConferenceTalk() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "general_conference_talks", withExtension: "json") else {
            XCTFail()
            return
        }
        do {
            var talks = try ConferenceTalk.load(from: path)
            
            XCTAssert(talks.count > 0)
            
            let noImageTalks = talks.filter {$0.thumbnail_url == nil}
            
            XCTAssert(noImageTalks.count > 0)
            
            talks.fillInMissingThumbnails()

            let noImageTalksCleaned = talks.filter {$0.thumbnail_url == nil}
            
            XCTAssert(noImageTalksCleaned.count > 0)
            XCTAssert(noImageTalksCleaned.count < talks.count)

        } catch {
            XCTFail()
        }
    }
    
}
