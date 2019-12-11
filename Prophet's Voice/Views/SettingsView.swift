//
//  ContentView.swift
//  Prophet's Voice
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Binding var show: Bool
    
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
                        Image(systemName: "chevron.left.circle.fill")
                            .scaleEffect(2.0)
                            .padding()
                            .accentColor(.black)
                    }
                    Spacer()
                }
                Spacer()
                Text("Settings")
                Spacer()
            }
            .foregroundColor(.red)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var show: Bool = true
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) {
            deviceName in SettingsView(show: $show)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
