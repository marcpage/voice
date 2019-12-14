//
//  ImageLoader.swift
//  Prophet's Voice
//
//  Created by Marc on 12/13/19.
//  Copyright © 2019 Resolve To Excel. All rights reserved.
//

import SwiftUI

class ImageLoader : ObservableObject {
    @Published var image:Image
    private let url:String
    private let placeholder:Image
    private let errorPlaceholder:Image = Image(systemName: "exclamationmark.icloud.fill")
    init(from: String, placeholder: Image=Image(systemName: "photo")) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        url = from
        self.placeholder = placeholder
        image = self.placeholder

        guard let urlLocation = URL(string:url) else {
            return
        }
        let request = URLRequest(url:urlLocation)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            var imageToDisplay = self.errorPlaceholder
            
            if let imageFile = tempLocalUrl {
                do {
                    if let uiImage = UIImage(data: try Data(contentsOf: imageFile)) {
                        imageToDisplay = Image(uiImage:  uiImage)
                    } else {
                        print("Unable to create UIImage from \(imageFile) loaded from \(self.url)")
                    }
                } catch {
                    print("Unable to load data from \(imageFile) loaded from \(self.url)")
                }
            } else if let err = error {
                print("error loading \(self.url): \(err)")
            } else {
                print("No local data for \(self.url)")
            }
            DispatchQueue.main.async {
                self.image = imageToDisplay
            }
        }
        task.resume()
    }
}
