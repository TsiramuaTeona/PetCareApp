//
//  RegisterViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Testing
import Foundation
@testable import PetCareApp

@Suite("RegisterViewModel")
@MainActor
struct RegisterViewModelTests {
    
    private func makeSUT(
        auth: AuthServiceMock = .init(),
        user: UserServiceMock = .init()
    ) -> (
        sut: RegisterViewModel, 
        auth: AuthServiceMock, 
        user: UserServiceMock
    ) {
        
        let sut = RegisterViewModel(authService: auth, userService: user)
        return (sut, auth, user)
    }
    
    @Test("register: invalid form -> no signUp call, field errors set")
    func register_invalidForm_doesNotCallSignUp() async {
        let (sut, auth, user) = makeSUT()
        
        sut.fullName = ""
        sut.email = "bad"
        sut.password = "123"
        sut.confirmPassword = "456"
        
        await sut.register()
        
        #expect(auth.signUpCalls.isEmpty)
        #expect(user.createCalls.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.showSuccessAlert == false)
        #expect(sut.fieldErrors.isEmpty == false)
    }
    
    @Test("register: signUp success but currentUserId nil -> signs out, sets formError, no profile created")
    func register_signUpButNoUID_signsOut_setsFormError() async {
        let (sut, auth, user) = makeSUT()
        
        sut.fullName = "A"
        sut.email = "a@b.com"
        sut.password = "Password1!"
        sut.confirmPassword = "Password1!"
        
        auth.currentUserId = nil
        
        await sut.register()
        
        #expect(auth.signUpCalls.count == 1)
        #expect(auth.signOutCallsCount == 1)
        #expect(user.createCalls.isEmpty)
        #expect(sut.formError != nil)
        #expect(sut.showSuccessAlert == false)
    }
    
    @Test("register: happy path -> signUp then create profile then success alert")
    func register_success_createsProfile_andShowsSuccess() async {
        let (sut, auth, user) = makeSUT()
        
        sut.fullName = "A User"
        sut.email = "a@b.com"
        sut.password = "Password1!"
        sut.confirmPassword = "Password1!"
        
        auth.currentUserId = "u1"
        
        await sut.register()
        
        #expect(auth.signUpCalls.count == 1)
        #expect(user.createCalls.count == 1)
        #expect(user.createCalls[0].id == "u1")
        #expect(user.createCalls[0].email == "a@b.com")
        #expect(user.createCalls[0].fullName == "A User")
        #expect(sut.showSuccessAlert == true)
        #expect(sut.formError == nil)
    }
    
    @Test("register: create profile fails -> signs out and sets formError")
    func register_profileCreateFails_signsOut_setsFormError() async {
        let (sut, auth, user) = makeSUT()
        
        sut.fullName = "A"
        sut.email = "a@b.com"
        sut.password = "Password1!"
        sut.confirmPassword = "Password1!"
        
        auth.currentUserId = "u1"
        user.createError = TestError.message("firestore down")
        
        await sut.register()
        
        #expect(auth.signUpCalls.count == 1)
        #expect(user.createCalls.count == 1)
        #expect(auth.signOutCallsCount == 1)
        #expect(sut.showSuccessAlert == false)
        #expect(sut.formError != nil)
    }
    
    @Test("changing fields clears errors + formError")
    func changingFields_clearsErrors() async {
        let (sut, _, _) = makeSUT()
        
        sut.fieldErrors[.email] = .invalidEmail
        sut.formError = "X"
        
        sut.email = "a@b.com"
        
        #expect(sut.fieldErrors[.email] == nil)
        #expect(sut.formError == nil)
    }
}
