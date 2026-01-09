//
//  ImageCache.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 09.01.26.
//


import SwiftUI
import Combine

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private var urlString: String?
    
    func load(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        
        self.urlString = urlString
        
        if let cachedImage = ImageCache.shared.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let loadedImage = UIImage(data: data) else { return }
                
                ImageCache.shared.setObject(loadedImage, forKey: urlString as NSString)
                
                self.image = loadedImage
                self.isLoading = false
            } catch {
                print("Image Load Error: \(error)")
                self.isLoading = false
            }
        }
    }
}
