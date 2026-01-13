//
//  ScreenStateContainer.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import SwiftUI

struct ScreenStateContainer<Content: View>: View {
    // MARK: - Properties
    
    let state: ScreenState
    let onRetry: () async -> Void
    @ViewBuilder let content: () -> Content

    // MARK: - Body
    
    var body: some View {
        switch state {

        case .loading:
            LoadingView()

        case .loaded:
            content()
                .background(.mainBackground)
                .refreshable {
                    Task {
                        await onRetry()
                    }
                }

        case .error(let message):
            ErrorStateView(
                message: message,
                onRetry: {
                    Task {
                        await onRetry()
                    }
                }
            )
        }
    }
}
