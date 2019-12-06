//
//  ContentView.swift
//  Prophet's Voice
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

struct TopicView: View {
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {withAnimation {self.show = false}}) {
                    Image(systemName: "chevron.down.circle.fill")
                        .scaleEffect(2.0)
                        .padding()
                        .accentColor(.black)
                }
            }
            Spacer()
            Text("Topics")
            Spacer()
        }
        .foregroundColor(.blue)
    }
}

struct TopicView_Previews: PreviewProvider {
    @State static var show: Bool = true
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) {
            deviceName in TopicView(show: $show)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
