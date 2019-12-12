//
//  ContentView.swift
//  Prophet's Voice
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var showSettings = false
    @State var showSpeakers = false
    @State var showTopics = false
    @State var playing = false
    @State var speaker : String? = nil
    @State var speakers : [String] = []
    @State var love = false
    @State var tags:[String] = []
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: UIScreen.main.bounds.width,
                       maxHeight: UIScreen.main.bounds.height)
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if showSettings {
                    SettingsView(show: $showSettings)
                        .transition(.move(edge: .leading))
                } else if showSpeakers {
                    SpeakerView(show: $showSpeakers, speaker: $speaker, speakers: speakers)
                        .transition(.move(edge: .bottom))
                } else if showTopics {
                    TopicView(show: $showTopics)
                        .transition(.move(edge: .bottom))
                } else {
                    HStack {
                        Button(action: {withAnimation {self.showSettings = true}}) {
                            Image(systemName: "gear")
                                .scaleEffect(2.0)
                                .padding()
                        }
                        Spacer()
                        Button(action: {self.love.toggle()}) {
                            Image(systemName: love ? "heart.fill" : "heart")
                                .scaleEffect(2.0)
                                .padding()
                        }
                        Button(action: {self.tags.append("another")}) {
                            Image(systemName: tags.count > 0 ? "tag.fill" : "tag")
                                .scaleEffect(2.0)
                                .padding()
                        }
                    }
                    Spacer()
                    CurrentTalkView()
                    Spacer().frame(height:20)
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "gobackward.30")
                                .scaleEffect(2.0)
                                .padding()
                        }
                        Spacer()
                        Button(action: {self.playing.toggle()}) {
                            Image(systemName: playing ? "pause.circle.fill" : "play.circle.fill")
                                .scaleEffect(playing ? 2.0 : 3.0)
                                .padding()
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "goforward.30")
                                .scaleEffect(2.0)
                                .padding()
                        }
                        Spacer()
                    }
                    Spacer().frame(height:30)
                    HStack {
                        Button(action: {withAnimation {self.showSpeakers = true}}) {
                            Image(systemName: "rectangle.stack.person.crop.fill")
                                .scaleEffect(2.0)
                                .padding()
                        }
                        Spacer()
                        Button(action: {withAnimation {self.showTopics = true}}) {
                            Image(systemName: "text.bubble.fill")
                                .scaleEffect(2.0)
                                .padding()
                        }
                    }
                }
            }
            .accentColor(.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ContentView(speakers: ["Thomas Monson", "Spencer W. Kimball"])
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
