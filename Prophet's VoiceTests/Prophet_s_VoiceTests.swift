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

    func testSpotCheckConferenceTalkUrls() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "general_conference_talks", withExtension: "json") else {
            XCTFail()
            return
        }
        do {
            let talks = try ConferenceTalk.load(from: path)
            let imageTalks = talks.filter {$0.thumbnail_url != nil}
            var urlsToTest: [String] = []
            
            XCTAssert(imageTalks.count > 3)
            
            urlsToTest.append(imageTalks[0].mp3_url)
            urlsToTest.append(imageTalks[imageTalks.count / 2].mp3_url)
            urlsToTest.append(imageTalks[imageTalks.count-1].mp3_url)
            if let url = imageTalks[0].thumbnail_url {
                urlsToTest.append(url)
            }
            if let url = imageTalks[imageTalks.count / 2].thumbnail_url {
                urlsToTest.append(url)
            }
            if let url = imageTalks[imageTalks.count-1].thumbnail_url {
                urlsToTest.append(url)
            }
            urlsToTest.append(imageTalks[0].url)
            urlsToTest.append(imageTalks[imageTalks.count / 2].url)
            urlsToTest.append(imageTalks[imageTalks.count-1].url)
            
            for url in urlsToTest {
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)

                guard let testUrl = URL(string:url) else {
                    XCTFail("Unable to create URL for: " + url)
                    continue
                }
                let request = URLRequest(url:testUrl)

                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let err = error {
                        XCTFail("Unable to get response for URL: " + url + " error: " + err.localizedDescription)
                    } else if tempLocalUrl != nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                        } else {
                            XCTFail("Unable to get response for URL: " + url)
                        }

                    } else {
                        XCTFail("We don't have a tempLocalUrl for URL: " + url)
                    }
                }
                task.resume()
            }

        } catch {
            XCTFail()
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
            XCTAssert(noImageTalksCleaned.count <= talks.count)

            let invalidTalkThumbUrls = talks.filter {($0.thumbnail_url?.starts(with: "http:") ?? false)}
            XCTAssert(invalidTalkThumbUrls.count == 0)

            let invalidTalkUrls = talks.filter {$0.url.starts(with: "http:")}
            XCTAssert(invalidTalkUrls.count == 0)

            let invalidTalkMp3Urls = talks.filter {$0.mp3_url.starts(with: "http:")}
            XCTAssert(invalidTalkMp3Urls.count == 0)

        } catch {
            XCTFail()
        }
    }
    
}
