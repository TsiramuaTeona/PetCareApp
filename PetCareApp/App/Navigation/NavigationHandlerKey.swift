//
//  NavigationHandlerKey.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

import SwiftUI

private struct NavigationHandlerKey: EnvironmentKey {
    static let defaultValue: (Destination) -> Void = { _ in }
}

extension EnvironmentValues {
    var navigate: (Destination) -> Void {
        get { self[NavigationHandlerKey.self] }
        set { self[NavigationHandlerKey.self] = newValue }
    }
}
