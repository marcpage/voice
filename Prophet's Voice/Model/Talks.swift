//
//  Talks.swift
//  Prophet's Voice
//
//  Created by Marc on 12/9/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import Foundation

enum TalkError: Error {
    case BundleFileNotFound(String)
}

struct ConferenceTalk : Codable {
    var identifier : String
    var conference : String
    var session : String
    var title : String
    var speaker : String
    var thumbnail_url : String?
    var mp3_url : String
    var url : String
}

extension ConferenceTalk {
    static func load(from url:URL) throws -> [ConferenceTalk]  {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        var talks = try JSONDecoder().decode([ConferenceTalk].self, from: data)
        
        talks.fixUnsecureUrls()
        return talks
    }
    static func load(named: String, withExtension: String) throws -> [ConferenceTalk] {
        guard let talkUrl = Bundle.main.url(forResource: named, withExtension: withExtension) else {
            throw TalkError.BundleFileNotFound(named + "." + withExtension)
        }
        return try load(from: talkUrl)
    }
}

extension Array where Element == ConferenceTalk {
    mutating func fillInMissingThumbnails() {
        var thumbnails : [String:String] = [:]
        
        for talk in self {
            if !thumbnails.contains {$0.key == talk.speaker} {
                if let thumbnail_url = talk.thumbnail_url {
                    thumbnails[talk.speaker] = thumbnail_url
                }
            }
        }
        
        for (index, talk) in self.enumerated() {
            if nil == talk.thumbnail_url && thumbnails.contains {$0.key == talk.speaker} {
                self[index].thumbnail_url = thumbnails[talk.speaker]
            }
        }
    }
    mutating func fixUnsecureUrls() {
        for (index, talk) in self.enumerated() {
            if let url = talk.thumbnail_url, url.starts(with: "http:") {
                self[index].thumbnail_url = url.replacingOccurrences(of: "http:", with: "https:")
            }
            if talk.mp3_url.starts(with: "http:") {
                self[index].mp3_url = talk.mp3_url.replacingOccurrences(of: "http:", with: "https:")
            }
            if talk.url.starts(with: "http:") {
                self[index].url = talk.url.replacingOccurrences(of: "http:", with: "https:")
            }
        }
    }

}

/*
 #!/usr/bin/swift

 import Foundation

 struct ConferenceTalk : Codable {
     var identifier : String
     var conference : String
     var session : String
     var title : String
     var speaker : String
     var thumbnail_url : String?
     var mp3_url : String
     var url : String
 }

 do {
     let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/marcp/Documents/Development/voice/Data/general_conference_talks.json"), options: .mappedIfSafe)
     let talks = try JSONDecoder().decode([ConferenceTalk].self, from: data)
     var thumbnails : [String:String] = [:]
     for talk in talks {
         if !thumbnails.contains {$0.key == talk.speaker} {
             if let thumbnail_url = talk.thumbnail_url {
                 thumbnails[talk.speaker] = thumbnail_url
             }
         }
     }
     print(talks[0].identifier)
     let noImageTalks = talks.filter {talk in
         return talk.thumbnail_url == nil && !thumbnails.contains {$0.key == talk.speaker}
     }

     print("\(noImageTalks.count) / \(talks.count) do not have an image")
     for talk in noImageTalks {
         print("\(talk.conference):\(talk.session):\(talk.session) \(talk.title) by \(talk.speaker)")
     }
   } catch {
        print("Error")
   }


 */
