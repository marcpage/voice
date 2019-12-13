//
//  ContentView.swift
//  Prophet's Voice
//
//  Created by Marc on 12/6/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

struct ImageUrlView: View {
    @ObservedObject var imageLoader:ImageLoader

    var body: some View {
        imageLoader.image
    }
}

struct ImageUrlView_Previews: PreviewProvider {
    @State static var talks = ConferenceTalk.tryLoad(defaultValue: [ConferenceTalk(identifier: "identifier", conference: "conference", session: "session", title: "title", speaker: "speaker", thumbnail_url: "thumbnail_url", mp3_url: "mp3_url", url: "url")])
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) {
            deviceName in
            ZStack {
                Rectangle().foregroundColor(.gray)
                ImageUrlView(imageLoader: ImageLoader(from:  "https://pixnio.com/free-images/flora-plants/flowers/roses-flower-pictures/red-rose-stock-image-725x544.jpg", placeholder: Image(systemName: "photo")))
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
}
