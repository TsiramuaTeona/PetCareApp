//
//  AppAlert.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 08.01.26.
//

import SwiftUI

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?

    func toAlert() -> Alert {
        if let secondaryButton {
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
}

extension AppAlert {
    static func error(_ message: String) -> AppAlert {
        AppAlert(
            title: "Error",
            message: message,
            primaryButton: .default(Text("OK")),
            secondaryButton: nil
        )
    }
    
    static func success(_ message: String) -> AppAlert {
        AppAlert(
            title: "Success",
            message: message,
            primaryButton: .default(Text("OK")),
            secondaryButton: nil
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
            primaryButton: .destructive(Text("Delete"), action: onConfirm),
            secondaryButton: .cancel()
        )
    }
    
    static func openSettings(
        title: String = "Permission Needed",
        message: String
    ) -> AppAlert {
        AppAlert(
            title: title,
            message: message,
            primaryButton: .default(Text("Open Settings"), action: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }),
            secondaryButton: .cancel(Text("Cancel"))
        )
    }
}
