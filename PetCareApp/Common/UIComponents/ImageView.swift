//
//  ImageView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 08.01.26.
//

import SwiftUI

struct ImageView: View {
    // MARK: - Properties
    
    @StateObject private var imageLoader = ImageLoader()
    
    let urlString: String?
    let contentMode: ContentMode
    let placeholderSystemImage: String
    let showsProgress: Bool
    
    // MARK: - Initializer
    
    init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        placeholderSystemImage: String = "pawprint.fill",
        showsProgress: Bool = true
    ) {
        self.urlString = urlString
        self.contentMode = contentMode
        self.placeholderSystemImage = placeholderSystemImage
        self.showsProgress = showsProgress
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .onAppear {
                imageLoader.load(from: urlString)
            }
            .onChange(of: urlString) { _, newValue in
                imageLoader.load(from: newValue)
            }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        ZStack {
            Color(.brandSecondary).opacity(0.1)
            
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if imageLoader.isLoading && showsProgress {
                LoadingView(pawCount: 1, size: 21)
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        Image(systemName: placeholderSystemImage)
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
            .foregroundColor(.brandSecondary.opacity(0.5))
    }
}
