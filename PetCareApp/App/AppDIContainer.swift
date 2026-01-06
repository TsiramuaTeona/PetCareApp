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
    lazy var petPhotoStorageService: PetPhotoStorageServiceProtocol = PetPhotoStorageService()
    lazy var mapService: MapServiceProtocol = MapService()
    lazy var locationService: LocationServiceProtocol = LocationService()
    
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
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            authService: authService,
            userService: userService,
            householdService: householdService,
            petService: petService
        )
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(
            authService: authService,
            userService: userService,
            householdService: householdService
        )
    }
    
    func makeAddPetViewModel(householdId: String) -> AddPetViewModel {
        return AddPetViewModel(
            householdId: householdId,
            petService: petService,
            photoStorageService: petPhotoStorageService
        )
    }
    
    func makeMapViewModel() -> MapViewModel {
        return MapViewModel(mapService: mapService)
    }
}
