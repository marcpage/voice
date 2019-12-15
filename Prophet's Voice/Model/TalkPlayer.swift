//
//  AudioPlayer.swift
//  Prophet's Voice
//
//  Created by Marc on 12/15/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI
import AVFoundation

class TalkPlayer : NSObject, ObservableObject {
    @Published var currentTalk:ConferenceTalk? = nil
    var filter = TalkFilter()
    let talks:[ConferenceTalk]
    var player: AVQueuePlayer? = nil
    private var playerContext = 0
    
    init(talks: [ConferenceTalk]) {
        self.talks = talks
        super.init()
        shuffle()
    }
    
    func change(filter: TalkFilter) {
        self.filter = filter
        shuffle()
    }
    
    func shuffle() {
        let playlist = talks.filter{return filter.canPlay(talk: $0)}.shuffled().map{return URL(string:$0.mp3_url)}.compactMap{$0}.map{AVPlayerItem(url: $0)}
        
        player?.pause()
        player = AVQueuePlayer(items: playlist)
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.new, .initial], context: &playerContext)

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        if keyPath == #keyPath(AVPlayer.currentItem) {
            if let talkUrl = (player?.currentItem?.asset as? AVURLAsset)?.url {
                let possibleTalks = talks.filter{ talk in
                    if let thisTalkUrl = URL(string: talk.mp3_url) {
                        return thisTalkUrl == talkUrl
                    }
                    return false
                }
                if possibleTalks.count > 0 {
                    DispatchQueue.main.async {
                        self.currentTalk = possibleTalks[0]
                    }
                }
            }
        }
    }

    func playPause() {
        if let havePlayer = player {
            if havePlayer.isPlaying {
                player?.pause()
            } else {
                player?.play()
            }
        }
    }
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
