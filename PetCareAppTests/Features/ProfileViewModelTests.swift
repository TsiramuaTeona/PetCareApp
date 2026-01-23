//
//  ProfileViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
import Testing
@testable import PetCareApp

@Suite("ProfileViewModel")
@MainActor
struct ProfileViewModelTests {

    private func makeSUT(
        auth: AuthServiceMock = .init(),
        userService: UserServiceMock = .init(),
        imageStorage: ImageStorageServiceMock = .init(),
        householdService: HouseholdServiceMock = .init(),
        themeManager: ThemeManagerMock = .init()
    ) -> (
        sut: ProfileViewModel,
        auth: AuthServiceMock,
        userService: UserServiceMock,
        imageStorage: ImageStorageServiceMock,
        householdService: HouseholdServiceMock,
        themeManager: ThemeManagerMock
    ) {

        let sut = ProfileViewModel(
            authService: auth,
            userService: userService,
            imageStorageService: imageStorage,
            householdService: householdService,
            themeManager: themeManager
        )

        return (sut, auth, userService, imageStorage, householdService, themeManager)
    }

    // MARK: - loadProfile

    @Test("loadProfile: no currentUserId -> returns early, state remains loading")
    func loadProfile_noUserId_returnsEarly() async {
        let (sut, auth, userService, _, householdService, _) = makeSUT()
        auth.currentUserId = nil

        await sut.loadProfile()

        #expect(sut.state == .loading)
        #expect(sut.user == nil)
        #expect(userService.getCalls.isEmpty)
        #expect(householdService.getCalls.isEmpty)
    }

    @Test("loadProfile: user without household -> sets user, household nil, sets loaded, fills drafts when not editing")
    func loadProfile_userNoHousehold_setsLoaded() async {
        let (sut, auth, userService, _, householdService, _) = makeSUT()
        auth.currentUserId = "u1"

        userService.usersById["u1"] = UserProfile(
            id: "u1",
            email: "a@b.com",
            fullName: "A",
            householdId: nil,
            createdAt: Date()
        )

        await sut.loadProfile()

        #expect(sut.state == .loaded)
        #expect(sut.user?.id == "u1")
        #expect(sut.household == nil)
        #expect(householdService.getCalls.isEmpty)

        #expect(sut.draftFullName == "A")
        #expect(sut.draftImageData == nil)
    }

    @Test("loadProfile: user with household -> fetches household and sets loaded")
    func loadProfile_userWithHousehold_fetchesHousehold() async {
        let (sut, auth, userService, _, householdService, _) = makeSUT()
        auth.currentUserId = "u1"

        userService.usersById["u1"] = UserProfile(
            id: "u1",
            email: "a@b.com",
            fullName: "A",
            householdId: "h1",
            createdAt: Date()
        )

        householdService.getResult = Household(
            id: "h1",
            name: "Home",
            joinCode: "ABC123",
            adminId: "u1",
            memberIds: ["u1"],
            createdAt: Date()
        )

        await sut.loadProfile()

        #expect(sut.state == .loaded)
        #expect(sut.household?.id == "h1")
        #expect(householdService.getCalls == ["h1"])
    }

    @Test("loadProfile: when editing -> does NOT overwrite drafts")
    func loadProfile_whenEditing_doesNotOverwriteDrafts() async {
        let (sut, auth, userService, _, _, _) = makeSUT()
        auth.currentUserId = "u1"

        userService.usersById["u1"] = UserProfile(
            id: "u1",
            email: "a@b.com",
            fullName: "Original",
            householdId: nil,
            createdAt: Date()
        )

        sut.isEditingProfile = true
        sut.draftFullName = "My Draft"
        sut.draftImageData = Data([0x01])

        await sut.loadProfile()

        #expect(sut.draftFullName == "My Draft")
        #expect(sut.draftImageData == Data([0x01]))
    }

    @Test("loadProfile failure -> sets error state")
    func loadProfile_failure_setsError() async {
        let (sut, auth, userService, _, _, _) = makeSUT()
        auth.currentUserId = "u1"
        userService.getError = TestError.message("boom")

        await sut.loadProfile()

        switch sut.state {
        case .error(let msg):
            #expect(msg.contains("boom") || msg.contains("message"))
        default:
            #expect(Bool(false), "Expected .error")
        }
    }

    // MARK: - editing

    @Test("startEditingProfile: copies current user into drafts and sets isEditingProfile")
    func startEditingProfile_setsDrafts() async {
        let (sut, _, _, _, _, _) = makeSUT()
        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())

        sut.startEditingProfile()

        #expect(sut.isEditingProfile == true)
        #expect(sut.draftFullName == "A")
        #expect(sut.draftImageData == nil)
    }

    @Test("cancelEditingProfile: restores name, clears image, stops editing")
    func cancelEditingProfile_restoresAndStops() async {
        let (sut, _, _, _, _, _) = makeSUT()
        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())
        sut.isEditingProfile = true
        sut.draftFullName = "Changed"
        sut.draftImageData = Data([0xFF])

        sut.cancelEditingProfile()

        #expect(sut.isEditingProfile == false)
        #expect(sut.draftFullName == "A")
        #expect(sut.draftImageData == nil)
    }

    // MARK: - canSaveProfile

    @Test("canSaveProfile: false when no user")
    func canSaveProfile_noUser_false() async {
        let (sut, _, _, _, _, _) = makeSUT()
        sut.user = nil
        #expect(sut.canSaveProfile == false)
    }

    @Test("canSaveProfile: true when name changed")
    func canSaveProfile_nameChanged_true() async {
        let (sut, _, _, _, _, _) = makeSUT()
        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())
        sut.draftFullName = "B"
        sut.draftImageData = nil

        #expect(sut.canSaveProfile == true)
    }

    @Test("canSaveProfile: true when photo set")
    func canSaveProfile_photoChanged_true() async {
        let (sut, _, _, _, _, _) = makeSUT()
        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())
        sut.draftFullName = "A"
        sut.draftImageData = Data([0x01])

        #expect(sut.canSaveProfile == true)
    }

    // MARK: - saveProfileChanges

    @Test("saveProfileChanges: uploads photo if draftImageData exists and updates user profile")
    func saveProfileChanges_withPhoto_uploadsAndUpdates() async {
        let (sut, auth, userService, imageStorage, _, _) = makeSUT()
        auth.currentUserId = "u1"

        userService.usersById["u1"] = UserProfile(
            id: "u1",
            email: "a@b.com",
            fullName: "Old",
            householdId: nil,
            photoUrl: "https://example.com/old.png",
            createdAt: Date()
        )
        sut.user = userService.usersById["u1"]

        sut.isEditingProfile = true
        sut.draftFullName = "New Name"
        sut.draftImageData = Data([0xAA])

        imageStorage.uploadUserImageResult = "https://example.com/new.png"

        await sut.saveProfileChanges()

        #expect(imageStorage.uploadUserCalls.count == 1)
        #expect(imageStorage.uploadUserCalls[0].userId == "u1")

        #expect(userService.updateProfileCalls.count == 1)
        #expect(userService.updateProfileCalls[0].userId == "u1")
        #expect(userService.updateProfileCalls[0].fullName == "New Name")
        #expect(userService.updateProfileCalls[0].photoUrl == "https://example.com/new.png")

        #expect(sut.isEditingProfile == false)
        #expect(sut.draftImageData == nil)
        #expect(sut.state == .loaded)
    }

    @Test("saveProfileChanges: upload fails -> sets alert error and state loaded")
    func saveProfileChanges_uploadFails_setsAlert() async {
        let (sut, auth, _, imageStorage, _, _) = makeSUT()
        auth.currentUserId = "u1"
        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())

        sut.isEditingProfile = true
        sut.draftFullName = "A"
        sut.draftImageData = Data([0x01])

        imageStorage.uploadUserImageError = TestError.message("upload fail")

        await sut.saveProfileChanges()

        #expect(sut.alert != nil)
        #expect(sut.state == .loaded)
    }

    // MARK: - createHousehold

    @Test("createHousehold: success -> calls services, clears input, shows success alert")
    func createHousehold_success() async {
        let (sut, _, userService, _, householdService, _) = makeSUT()

        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())
        sut.newHouseholdName = "My House"

        householdService.createResult = Household(
            id: "h1",
            name: "My House",
            joinCode: "ZZZ111",
            adminId: "u1",
            memberIds: ["u1"],
            createdAt: Date()
        )

        userService.usersById["u1"] = sut.user!

        await sut.createHousehold()

        #expect(householdService.createCalls.count == 1)
        #expect(householdService.createCalls[0].name == "My House")
        #expect(householdService.createCalls[0].adminId == "u1")

        #expect(userService.updateHouseholdCalls.count == 1)
        #expect(userService.updateHouseholdCalls[0].householdId == "h1")

        #expect(sut.newHouseholdName == "")
        #expect(sut.alert?.title == "Success")
        #expect(sut.state == .loaded)
    }

    @Test("createHousehold: failure -> sets error alert, state loaded")
    func createHousehold_failure_setsAlert() async {
        let (sut, _, userService, _, householdService, _) = makeSUT()
        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())
        sut.newHouseholdName = "My House"

        userService.usersById["u1"] = sut.user!
        householdService.createError = TestError.message("create fail")

        await sut.createHousehold()

        #expect(sut.alert != nil)
        #expect(sut.state == .loaded)
    }

    // MARK: - joinHousehold

    @Test("joinHousehold: success -> uppercases code, updates householdId, clears input, shows success")
    func joinHousehold_success() async {
        let (sut, _, userService, _, householdService, _) = makeSUT()

        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())
        userService.usersById["u1"] = sut.user!

        sut.joinCodeInput = "abc123"

        householdService.joinResult = Household(
            id: "h1",
            name: "Home",
            joinCode: "ABC123",
            adminId: "u1",
            memberIds: ["u1"],
            createdAt: Date()
        )

        await sut.joinHousehold()

        #expect(householdService.joinCalls.count == 1)
        #expect(householdService.joinCalls[0].code == "ABC123")

        #expect(userService.updateHouseholdCalls.count == 1)
        #expect(userService.updateHouseholdCalls[0].householdId == "h1")

        #expect(sut.joinCodeInput == "")
        #expect(sut.alert?.title == "Success")
        #expect(sut.state == .loaded)
    }

    @Test("joinHousehold: failure -> sets error alert, clears input, calls loadProfile")
    func joinHousehold_failure_setsAlert_andReloads() async {
        let (sut, auth, userService, _, householdService, _) = makeSUT()

        auth.currentUserId = "u1"
        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: nil, createdAt: Date())
        userService.usersById["u1"] = sut.user!
        
        sut.joinCodeInput = "abc123"
        householdService.joinError = TestError.message("join fail")
        
        await sut.joinHousehold()
        
        #expect(sut.alert != nil)
        #expect(sut.joinCodeInput == "")
        #expect(userService.getCalls.contains("u1"))
    }

    // MARK: - leaveHousehold

    @Test("leaveHousehold: success -> leaves, sets user household nil, reloads, shows success")
    func leaveHousehold_success() async {
        let (sut, _, userService, _, householdService, _) = makeSUT()

        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: "h1", createdAt: Date())
        sut.household = Household(id: "h1", name: "Home", joinCode: "ABC123", adminId: "u1", memberIds: ["u1"], createdAt: Date())

        userService.usersById["u1"] = sut.user!

        await sut.leaveHousehold()

        #expect(householdService.leaveCalls.count == 1)
        #expect(householdService.leaveCalls[0].id == "h1")
        #expect(householdService.leaveCalls[0].userId == "u1")

        #expect(userService.updateHouseholdCalls.count == 1)
        #expect(userService.updateHouseholdCalls[0].householdId == nil)

        #expect(sut.alert?.title == "Success")
        #expect(sut.state == .loaded)
    }

    @Test("leaveHousehold: failure -> sets error alert, state loaded")
    func leaveHousehold_failure_setsAlert() async {
        let (sut, _, userService, _, householdService, _) = makeSUT()

        sut.user = UserProfile(id: "u1", email: "a@b.com", fullName: "A", householdId: "h1", createdAt: Date())
        sut.household = Household(id: "h1", name: "Home", joinCode: "ABC123", adminId: "u1", memberIds: ["u1"], createdAt: Date())

        userService.usersById["u1"] = sut.user!

        householdService.leaveError = TestError.message("leave fail")

        await sut.leaveHousehold()

        #expect(sut.alert != nil)
        #expect(sut.state == .loaded)
    }

    // MARK: - signOut

    @Test("signOut: success -> calls authService.signOut")
    func signOut_success_callsAuth() async {
        let (sut, auth, _, _, _, _) = makeSUT()

        await sut.signOut()

        #expect(auth.signOutCallsCount == 1)
    }

    @Test("signOut: failure -> sets error state")
    func signOut_failure_setsErrorState() async {
        let (sut, auth, _, _, _, _) = makeSUT()
        auth.signOutError = TestError.message("nope")

        await sut.signOut()

        switch sut.state {
        case .error(let msg):
            #expect(msg.contains("Sign out failed"))
        default:
            #expect(Bool(false), "Expected .error")
        }
    }
}
