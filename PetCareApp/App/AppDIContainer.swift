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
    lazy var imageStorageService: ImageStorageServiceProtocol = ImageStorageService()
    lazy var mapService: MapServiceProtocol = MapService()
    lazy var locationService: LocationServiceProtocol = LocationService()
    lazy var healthService: HealthServiceProtocol = HealthService()
    lazy var reminderSyncService: ReminderSyncServiceProtocol = {
        return ReminderSyncService(petService: petService, healthService: healthService)
    }()
    
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
            petService: petService,
            healthService: healthService,
            reminderSyncService: reminderSyncService
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
            imageStorageService: imageStorageService
        )
    }
    
    func makePetDetailsViewModel(pet: Pet) -> PetDetailsViewModel {
        return PetDetailsViewModel(
            pet: pet,
            petService: petService,
            healthService: healthService
        )
    }
    
    func makeEditPetViewModel(pet: Pet) -> EditPetViewModel {
        return EditPetViewModel(
            pet: pet,
            petService: petService,
            imageStorageService: imageStorageService
        )
    }
    
    func makeAddHealthLogViewModel(petId: String, category: LogCategory) -> AddHealthLogViewModel {
        return AddHealthLogViewModel(
            petId: petId,
            category: category,
            healthService: healthService,
            reminderService: reminderSyncService
        )
    }
    
    func makeLogDetailsViewModel(petId: String, log: HealthLog) -> LogDetailsViewModel {
        return LogDetailsViewModel(
            petId: petId,
            sourceLog: log,
            healthService: healthService,
            reminderService: reminderSyncService
        )
    }
    
    func makeMapViewModel() -> MapViewModel {
        return MapViewModel(mapService: mapService)
    }
    
    func makeReminderSyncService() -> ReminderSyncService {
        return ReminderSyncService(petService: petService, healthService: healthService)
    }
}
