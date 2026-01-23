//
//  ThemeManagerMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

@testable import PetCareApp

final class ThemeManagerMock: ThemeManaging {
    var theme: AppTheme = .system

    private(set) var setThemeCalls: [AppTheme] = []
    private(set) var applyCalls = 0

    func setTheme(_ theme: AppTheme) {
        setThemeCalls.append(theme)
        self.theme = theme
    }

    func applyThemeToAllWindows() {
        applyCalls += 1
    }
}
