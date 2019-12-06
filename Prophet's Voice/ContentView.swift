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
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: UIScreen.main.bounds.width,
                       maxHeight: UIScreen.main.bounds.height)
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if showSettings {
                    SettingsView(show: $showSettings)
                        .transition(.move(edge: .trailing))
                } else if showSpeakers {
                    SpeakerView(show: $showSpeakers)
                        .transition(.move(edge: .bottom))
                } else if showTopics {
                    TopicView(show: $showTopics)
                        .transition(.move(edge: .bottom))
                } else {
                    HStack {
                        Spacer()
                        Button(action: {withAnimation {self.showSettings = true}}) {
                            Image(systemName: "gear")
                                .scaleEffect(2.0)
                                .padding()
                                .accentColor(.black)
                        }
                    }
                    Spacer()
                    HStack {
                        Button(action: {withAnimation {self.showSpeakers = true}}) {
                            Image(systemName: "rectangle.stack.person.crop.fill")
                                .scaleEffect(2.0)
                                .padding()
                                .accentColor(.black)
                        }
                        Spacer()
                        Button(action: {withAnimation {self.showTopics = true}}) {
                            Image(systemName: "text.bubble.fill")
                                .scaleEffect(2.0)
                                .padding()
                                .accentColor(.black)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ContentView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
