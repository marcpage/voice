//
//  ContentView.swift
//  Prophet's Voice
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

struct CurrentTalkView: View {
    
    var body: some View {
        VStack {
            Text("What should I say?")
                .foregroundColor(.white)
                .font(.headline)
                .fontWeight(.heavy)
            Text("Spencer W. Kimball")
                .foregroundColor(.white)
            Text("April 2019")
                .foregroundColor(.white)
            Text("Saturday Morning Session")
                .foregroundColor(.white)
        }
    }
}

struct CurrentTalkView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) {
            deviceName in CurrentTalkView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
