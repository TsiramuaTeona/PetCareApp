//
//  PhotoPickerView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 08.01.26.
//

import PhotosUI
import SwiftUI

struct PhotoPickerView: View {
    // MARK: - Properties
    
    @State private var selectedItem: PhotosPickerItem?
    
    @Binding var imageData: Data?
    var imageURL: String? = nil
    let size: CGFloat
    
    private var hasImage: Bool {
        return imageData != nil || imageURL != nil
    }
    
    // MARK: - Body
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            content
        }
        .onChange(of: selectedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let compressed = image.jpegData(compressionQuality: 0.6) {
                    imageData = compressed
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var content: some View {
        VStack(spacing: 12) {
            ZStack {
                if let imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let imageURL {
                    ImageView(urlString: imageURL, contentMode: .fill)
                } else {
                    placeholderView
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(alignment: .bottomTrailing) { cameraBadge }
            
            Text(hasImage ? "Change Photo" : "Add Photo")
                .font(.appBody)
                .fontWeight(.medium)
                .foregroundColor(.brandPrimary)
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Color.brandSecondary.opacity(0.15))
            
            Image(systemName: "pawprint.fill")
                .font(.largeTitle)
                .foregroundColor(.brandSecondary)
        }
    }
    
    private var cameraBadge: some View {
        Image(systemName: "camera.fill")
            .foregroundColor(.white)
            .padding(8)
            .background(Color.brandPrimary)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .offset(x: -4, y: -4)
    }
}
