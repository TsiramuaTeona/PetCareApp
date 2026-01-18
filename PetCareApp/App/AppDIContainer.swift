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
    lazy var aiService: AIChatServiceProtocol = AIChatService()
    lazy var calendarService: CalendarServiceProtocol = CalendarService()
    
    lazy var themeManager: ThemeManager = {
        let manager = ThemeManager()
        manager.applyThemeToAllWindows()
        return manager
    }()

    
    lazy var reminderSyncService: ReminderSyncServiceProtocol = {
        ReminderSyncService(petService: petService, healthService: healthService)
    }()
    
    // MARK: - ViewModels
    
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService)
    }
    
    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authService: authService, userService: userService)
    }
    
    func makeResetPasswordViewModel() -> ResetPasswordViewModel {
        ResetPasswordViewModel(authService: authService)
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            authService: authService,
            userService: userService,
            householdService: householdService,
            petService: petService,
            healthService: healthService,
            reminderSyncService: reminderSyncService
        )
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            authService: authService,
            userService: userService,
            imageStorageService: imageStorageService,
            householdService: householdService,
            themeManager: themeManager
        )
    }
    
    func makeAddPetViewModel(householdId: String) -> AddPetViewModel {
        AddPetViewModel(
            householdId: householdId,
            petService: petService,
            imageStorageService: imageStorageService
        )
    }
    
    func makePetDetailsViewModel(pet: Pet) -> PetDetailsViewModel {
        PetDetailsViewModel(
            pet: pet,
            petService: petService,
            healthService: healthService
        )
    }
    
    func makeEditPetViewModel(pet: Pet) -> EditPetViewModel {
        EditPetViewModel(
            pet: pet,
            petService: petService,
            imageStorageService: imageStorageService
        )
    }
    
    func makeAddHealthLogViewModel(petId: String, category: LogCategory)
    -> AddHealthLogViewModel
    {
        AddHealthLogViewModel(
            petId: petId,
            category: category,
            healthService: healthService,
            reminderService: reminderSyncService
        )
    }
    
    func makeLogDetailsViewModel(petId: String, petName: String, log: HealthLog)
    -> LogDetailsViewModel
    {
        LogDetailsViewModel(
            petId: petId,
            petName: petName,
            sourceLog: log,
            healthService: healthService,
            calendarService: calendarService,
            reminderService: reminderSyncService
        )
    }
    
    func makeMapViewModel() -> MapViewModel {
        MapViewModel(mapService: mapService)
    }
    
    func makeChatViewModel() -> ChatViewModel {
        let aiService: AIChatServiceProtocol = AIChatService()
        
        return ChatViewModel(
            authService: authService,
            userService: userService,
            petService: petService,
            healthService: healthService,
            aiService: aiService
        )
    }
}
