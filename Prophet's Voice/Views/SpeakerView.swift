//
//  ContentView.swift
//  Prophet's Voice
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

struct SpeakerView: View {
    @Binding var show: Bool
    @Binding var speaker : String?
    @State var speakers : [String]
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: UIScreen.main.bounds.width,
                       maxHeight: UIScreen.main.bounds.height)
            VStack {
                HStack {
                    Button(action: {withAnimation {self.show = false}}) {
                        Image(systemName: "chevron.down.circle.fill")
                            .scaleEffect(2.0)
                            .padding()
                    }
                    Spacer()
                }
                Text(nil == speaker ? "None" : speaker!)
                List(speakers, id: \.self) {aSpeaker in
                    HStack {
                        Spacer().frame(width: 10)
                        Button(action: {}) {
                            Image(systemName: aSpeaker == self.speaker ? "largecircle.fill.circle" : "circle")
                        }
                            .onTapGesture {
                                self.speaker = aSpeaker
                            }
                        Spacer()
                            .frame(width: 10)
                        Image(systemName: "person.circle.fill")
                            .scaleEffect(1.5)
                        Text(aSpeaker)
                    }
                }
            }
            .foregroundColor(.green)
        }
    }
}

struct SpeakerView_Previews: PreviewProvider {
    @State static var show: Bool = true
    @State static var speaker : String? = "Thomas S. Monson"
    
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) {
            deviceName in SpeakerView(show: $show, speaker: $speaker, speakers: ["Thomas S. Monson", "Spencer W. Kimball"])
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
