//
//  Destination.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//

enum Destination {
    case login
    case register
    case resetPassword
    
    case mainTabs
    
    case selectTab(MainTab)
    
    case petDetails(pet: Pet)
    case addPet(householdId: String)
    case editPet(pet: Pet, onSave: (Pet) -> Void)
    case addHealthLog(
        petId: String,
        category: LogCategory = .vaccine,
        onSave: () -> Void
    )
    case logDetails(petId: String, petName: String, log: HealthLog)
    case remindersList(items: [ReminderItem])
}
