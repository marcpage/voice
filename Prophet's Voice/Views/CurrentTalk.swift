//
//  ContentView.swift
//  Prophet's Voice
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

struct CurrentTalkView: View {
    @State var talk: ConferenceTalk
    
    var body: some View {
        VStack {
            Spacer()
            ImageUrlView(imageLoader: ImageLoader(from: talk.thumbnail_url ?? "", placeholder: Image(systemName: "photo")))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            Spacer()
            Text(talk.title)
                .foregroundColor(.white)
                .font(.headline)
                .fontWeight(.heavy)
            Text(talk.speaker)
                .foregroundColor(.white)
            Text(talk.conference)
                .foregroundColor(.white)
            Text(talk.session)
                .foregroundColor(.white)
        }
    }
}

struct CurrentTalkView_Previews: PreviewProvider {
    @State static var talks = ConferenceTalk.tryLoad(defaultValue: [ConferenceTalk(identifier: "identifier", conference: "conference", session: "session", title: "title", speaker: "speaker", thumbnail_url: "thumbnail_url", mp3_url: "mp3_url", url: "url")])
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) {
            deviceName in
            ZStack {
                Rectangle().foregroundColor(.gray)
                CurrentTalkView(talk: talks[0])
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
}
