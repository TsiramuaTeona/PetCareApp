//
//  HomeViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {
    
    private func makeSUT(
        auth: AuthServiceMock = .init(),
        userService: UserServiceMock = .init(),
        householdService: HouseholdServiceMock = .init(),
        petService: PetServiceMock = .init(),
        healthService: HealthServiceMock = .init(),
        reminderSync: ReminderSyncServiceMock = .init(),
        notification: NotificationServiceMock = .init(),
        firebase: FirebaseUserProviding = FirebaseUserProviderMock(email: nil, displayName: nil)
    ) -> HomeViewModel {
        HomeViewModel(
            authService: auth,
            userService: userService,
            householdService: householdService,
            petService: petService,
            healthService: healthService,
            reminderSyncService: reminderSync,
            notificationService: notification,
            firebaseUserProvider: firebase
        )
    }
    
    @Test("No currentUserId -> clears and sets error")
    func noUserId_setsError_andClears() async {
        let auth = AuthServiceMock()
        auth.currentUserId = nil
        
        let userService = UserServiceMock()
        let householdService = HouseholdServiceMock()
        let petService = PetServiceMock()
        let healthService = HealthServiceMock()
        let reminderSync = ReminderSyncServiceMock()
        let notification = NotificationServiceMock()
        
        let firebase = FirebaseUserProviderMock(email: "x@y.com", displayName: "X")
        
        let sut = makeSUT(
            auth: auth,
            userService: userService,
            householdService: householdService,
            petService: petService,
            healthService: healthService,
            reminderSync: reminderSync,
            notification: notification,
            firebase: firebase
        )
        
        await sut.loadData()
        
        #expect(sut.user == nil)
        #expect(sut.household == nil)
        #expect(sut.pets.isEmpty)
        #expect(sut.upcomingReminders.isEmpty)
        
        #expect(reminderSync.stopListeningCallsCount == 1)
        #expect(notification.cancelAllCalls == 1)
        
        switch sut.state {
        case .error(let msg):
            #expect(msg == "User not authenticated")
        default:
            #expect(Bool(false), "Expected .error state")
        }
    }
    
    @Test("User exists, no householdId -> loaded, clears household data, cancels reminders")
    func userNoHousehold_loaded_andCancels() async {
        let auth = AuthServiceMock()
        auth.currentUserId = "u1"
        
        let userService = UserServiceMock()
        userService.usersById["u1"] = UserProfile(
            id: "u1",
            email: "a@b.com",
            fullName: "A",
            householdId: nil,
            createdAt: Date()
        )
        
        let householdService = HouseholdServiceMock()
        let petService = PetServiceMock()
        let healthService = HealthServiceMock()
        let reminderSync = ReminderSyncServiceMock()
        let notification = NotificationServiceMock()
        
        let firebase = FirebaseUserProviderMock(email: "fb@fb.com", displayName: "FB")
        
        let sut = makeSUT(
            auth: auth,
            userService: userService,
            householdService: householdService,
            petService: petService,
            healthService: healthService,
            reminderSync: reminderSync,
            notification: notification,
            firebase: firebase
        )
        
        await sut.loadData()
        
        #expect(sut.user?.id == "u1")
        #expect(sut.household == nil)
        #expect(sut.pets.isEmpty)
        #expect(sut.upcomingReminders.isEmpty)
        
        #expect(notification.cancelAllCalls == 1)
        #expect(reminderSync.stopListeningCallsCount == 1)
        
        #expect(householdService.getCalls.isEmpty)
        #expect(petService.getPetsCalls.isEmpty)
        
        switch sut.state {
        case .loaded: break
        default:
            #expect(Bool(false), "Expected .loaded state")
        }
    }
    
    @Test("Household flow -> loads household + pets + reminders, syncs when household changes")
    func householdFlow_loadsAndSyncs() async {
        let auth = AuthServiceMock()
        auth.currentUserId = "u1"
        
        let userService = UserServiceMock()
        userService.usersById["u1"] = UserProfile(
            id: "u1",
            email: "a@b.com",
            fullName: "A",
            householdId: "h1",
            createdAt: Date()
        )
        
        let householdService = HouseholdServiceMock()
        householdService.getResult = Household(
            id: "h1",
            name: "Home",
            joinCode: "ABC123",
            adminId: "u1",
            memberIds: ["u1"],
            createdAt: Date()
        )
        
        let pet1 = Pet(
            id: "p1",
            householdId: "h1",
            name: "Luna",
            species: .cat,
            breed: nil,
            gender: .female,
            birthDate: Date(),
            photoUrl: nil,
            createdAt: Date()
        )
        
        let pet2 = Pet(
            id: "p2",
            householdId: "h1",
            name: "Max",
            species: .dog,
            breed: nil,
            gender: .male,
            birthDate: Date(),
            photoUrl: nil,
            createdAt: Date()
        )
        
        let petService = PetServiceMock()
        petService.petsByHouseholdId["h1"] = [pet1, pet2]
        
        let healthService = HealthServiceMock()
        
        let dueSoon = DateFactory.make(year: 2025, month: 1, day: 10, hour: 9, minute: 0)
        let dueLater = DateFactory.make(year: 2025, month: 1, day: 11, hour: 9, minute: 0)
        
        healthService.logsByPetId["p1"] = [
            HealthLog(
                id: "l1",
                petId: "p1",
                category: .vaccine,
                title: "Rabies",
                note: nil,
                date: dueSoon,
                isResolved: false,
                completedDate: nil,
                nextDueDate: dueLater,
                recurrence: nil,
                value: nil,
                dosage: nil,
                timesPerDay: nil,
                reminderTimes: nil,
                durationDays: nil,
                medicationCourseStart: nil
            ),
            HealthLog(
                id: "l2",
                petId: "p1",
                category: .vet,
                title: "Visit",
                note: nil,
                date: dueSoon,
                isResolved: false,
                completedDate: nil,
                nextDueDate: dueSoon,
                recurrence: nil,
                value: nil,
                dosage: nil,
                timesPerDay: nil,
                reminderTimes: nil,
                durationDays: nil,
                medicationCourseStart: nil
            )
        ]
        
        healthService.logsByPetId["p2"] = [
            HealthLog(
                id: "l3",
                petId: "p2",
                category: .weight,
                title: "4.2 kg",
                note: nil,
                date: dueSoon,
                isResolved: true,
                completedDate: dueSoon,
                nextDueDate: nil,
                recurrence: nil,
                value: 4.2,
                dosage: nil,
                timesPerDay: nil,
                reminderTimes: nil,
                durationDays: nil,
                medicationCourseStart: nil
            )
        ]
        
        let reminderSync = ReminderSyncServiceMock()
        let notification = NotificationServiceMock()
        let firebase = FirebaseUserProviderMock(email: "fb@x.com", displayName: "FB")
        
        let sut = makeSUT(
            auth: auth,
            userService: userService,
            householdService: householdService,
            petService: petService,
            healthService: healthService,
            reminderSync: reminderSync,
            notification: notification,
            firebase: firebase
        )
        
        await sut.loadData()
        
        #expect(sut.household?.id == "h1")
        #expect(sut.pets.count == 2)
        
        #expect(sut.upcomingReminders.count == 2)
        #expect(sut.upcomingReminders[0].log.id == "l2")
        #expect(sut.upcomingReminders[1].log.id == "l1")
        
        #expect(notification.cancelAllCalls == 1)
        #expect(reminderSync.syncAllCalls == ["h1"])
        #expect(reminderSync.startListeningCalls == ["h1"])
        
        switch sut.state {
        case .loaded: break
        default:
            #expect(Bool(false), "Expected .loaded state")
        }
    }
}
