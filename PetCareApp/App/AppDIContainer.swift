//
//  AppDIContainer.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


final class AppDIContainer {

    // MARK: - Services

    lazy var authService: AuthServiceProtocol = AuthService()
    lazy var userService: UserServiceProtocol = UserService()
    lazy var householdService: HouseholdServiceProtocol = HouseholdService()
    lazy var petService: PetServiceProtocol = PetService()

    // MARK: - ViewModels

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService)
    }
    
    func makeRegisterViewModel() -> RegisterViewModel {
        return RegisterViewModel(
            authService: authService,
            userService: userService
        )
    }
    
    func makeResetPasswordViewModel() -> ResetPasswordViewModel {
        return ResetPasswordViewModel(authService: authService)
    }
}
