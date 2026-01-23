//
//  AppAlert.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 08.01.26.
//

import SwiftUI

import SwiftUI

struct AppAlert: Identifiable {
    enum ActionStyle {
        case `default`
        case cancel
        case destructive
    }
    
    struct Action {
        let title: String
        let style: ActionStyle
        let handler: (() -> Void)?
    }
    
    let id = UUID()
    let title: String
    let message: String?
    
    let primary: Action
    let secondary: Action?
    
    func toAlert() -> Alert {
        let primaryButton = toAlertButton(primary)
        if let secondary {
            let secondaryButton = toAlertButton(secondary)
            return Alert(
                title: Text(title),
                message: message.map(Text.init),
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        } else {
            return Alert(
                title: Text(title),
                message: message.map(Text.init),
                dismissButton: primaryButton
            )
        }
    }
    
    private func toAlertButton(_ action: Action) -> Alert.Button {
        switch action.style {
        case .default:
            return .default(Text(action.title), action: action.handler)
        case .cancel:
            if let handler = action.handler {
                return .cancel(Text(action.title), action: handler)
            } else {
                return .cancel(Text(action.title))
            }
        case .destructive:
            return .destructive(Text(action.title), action: action.handler)
        }
    }
}

extension AppAlert {
    static func error(_ message: String) -> AppAlert {
        AppAlert(
            title: "Error",
            message: message,
            primary: .init(title: "OK", style: .default, handler: nil),
            secondary: nil
        )
    }
    
    static func success(_ message: String) -> AppAlert {
        AppAlert(
            title: "Success",
            message: message,
            primary: .init(title: "OK", style: .default, handler: nil),
            secondary: nil
        )
    }
    
    static func deleteConfirmation(
        title: String,
        message: String,
        onConfirm: @escaping () -> Void
    ) -> AppAlert {
        AppAlert(
            title: title,
            message: message,
            primary: .init(title: "Delete", style: .destructive, handler: onConfirm),
            secondary: .init(title: "Cancel", style: .cancel, handler: nil)
        )
    }
    
    static func openSettings(
        title: String = "Permission Needed",
        message: String
    ) -> AppAlert {
        AppAlert(
            title: title,
            message: message,
            primary: .init(title: "Open Settings", style: .default, handler: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }),
            secondary: .init(title: "Cancel", style: .cancel, handler: nil)
        )
    }
}
