//
//  LoginViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Testing
import Foundation
@testable import PetCareApp

@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {
    
    private func makeSUT(
        auth: AuthServiceMock = .init()
    ) -> (
        sut: LoginViewModel,
        auth: AuthServiceMock
    ) {
        let sut = LoginViewModel(authService: auth)
        return (sut, auth)
    }
    
    @Test("login: invalid form -> does not call signIn, sets field errors, not loading")
    func login_invalidForm_doesNotCallSignIn() async {
        let (sut, auth) = makeSUT()
        
        sut.email = "not-an-email"
        sut.password = ""
        
        await sut.login()
        
        #expect(auth.signInCalls.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.formError == nil)
        #expect(sut.fieldErrors[.email] != nil)
        #expect(sut.fieldErrors[.password] != nil)
    }
    
    @Test("login: valid form -> calls signIn with email/password")
    func login_valid_callsSignIn() async {
        let (sut, auth) = makeSUT()
        
        sut.email = "a@b.com"
        sut.password = "123456"
        
        await sut.login()
        
        #expect(auth.signInCalls.count == 1)
        #expect(auth.signInCalls[0].email == "a@b.com")
        #expect(auth.signInCalls[0].password == "123456")
        #expect(sut.formError == nil)
        #expect(sut.isLoading == false)
    }
    
    @Test("login: signIn throws -> sets formError")
    func login_signInFailure_setsFormError() async {
        let (sut, auth) = makeSUT()
        auth.signInError = TestError.message("bad credentials")
        
        sut.email = "a@b.com"
        sut.password = "123456"
        
        await sut.login()
        
        #expect(auth.signInCalls.count == 1)
        #expect(sut.formError != nil)
    }
    
    @Test("googleButtonTapped -> sets loading and triggers callback")
    func googleButtonTapped_setsLoading_andCallsCallback() async {
        let (sut, _) = makeSUT()
        
        var called = 0
        sut.onGoogleSignInRequested = { called += 1 }
        
        sut.googleButtonTapped()
        
        #expect(sut.isLoading == true)
        #expect(called == 1)
    }
    
    @Test("handleGoogleSignInResult success -> stops loading, keeps formError nil")
    func googleResult_success() async {
        let (sut, _) = makeSUT()
        sut.isLoading = true
        
        sut.handleGoogleSignInResult(.success(()))
        
        #expect(sut.isLoading == false)
        #expect(sut.formError == nil)
    }
    
    @Test("handleGoogleSignInResult failure -> stops loading, sets cancelled message")
    func googleResult_failure_setsCancelledError() async {
        let (sut, _) = makeSUT()
        sut.isLoading = true
        
        sut.handleGoogleSignInResult(.failure(TestError.stubbed))
        
        #expect(sut.isLoading == false)
        #expect(sut.formError == AuthError.googleSignCancelled.localizedDescription)
    }
    
    @Test("changing email/password clears field error and formError")
    func changingFields_clearsErrors() async {
        let (sut, _) = makeSUT()
        
        sut.fieldErrors[.email] = .invalidEmail
        sut.fieldErrors[.password] = .required
        sut.formError = "X"
        
        sut.email = "a@b.com"
        
        #expect(sut.fieldErrors[.email] == nil)
        #expect(sut.formError == nil)
        
        sut.password = "123"
        
        #expect(sut.fieldErrors[.password] == nil)
        #expect(sut.formError == nil)
    }
}
