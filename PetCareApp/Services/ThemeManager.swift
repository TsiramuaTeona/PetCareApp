//
//  ThemeManager.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 18.01.26.
//

import Combine
import Foundation
import UIKit

protocol ThemeManaging: AnyObject {
    var theme: AppTheme { get }
    func setTheme(_ theme: AppTheme)
    func applyThemeToAllWindows()
}

@MainActor
final class ThemeManager: ObservableObject, ThemeManaging {

    // MARK: - Properties

    @Published private(set) var theme: AppTheme

    private let key = "app_theme_preference"

    // MARK: - Initializer

    init() {
        let raw = UserDefaults.standard.string(forKey: key)
        self.theme = AppTheme(rawValue: raw ?? "") ?? .system
    }

    // MARK: - Methods

    func setTheme(_ theme: AppTheme) {
        self.theme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: key)
        applyThemeToAllWindows()
    }

    func applyThemeToAllWindows() {
        let style = theme.uiStyle

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}
