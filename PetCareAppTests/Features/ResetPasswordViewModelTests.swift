//
//  ResetPasswordViewModelTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Testing
import Foundation
@testable import PetCareApp

@Suite("ResetPasswordViewModel")
@MainActor
struct ResetPasswordViewModelTests {
    
    private func makeSUT(
        auth: AuthServiceMock = .init()
    ) -> (sut: ResetPasswordViewModel, auth: AuthServiceMock) {
        
        let sut = ResetPasswordViewModel(authService: auth)
        return (sut, auth)
    }
    
    @Test("resetPassword: invalid email -> sets errorMessage, no call")
    func reset_invalidEmail_setsError_noCall() async {
        let (sut, auth) = makeSUT()
        sut.email = "bad"
        
        await sut.resetPassword()
        
        #expect(auth.resetPasswordCalls.isEmpty)
        #expect(sut.showSuccessAlert == false)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
    }
    
    @Test("resetPassword: success -> calls service, shows success alert")
    func reset_success() async {
        let (sut, auth) = makeSUT()
        sut.email = "a@b.com"
        
        await sut.resetPassword()
        
        #expect(auth.resetPasswordCalls == ["a@b.com"])
        #expect(sut.showSuccessAlert == true)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }
    
    @Test("resetPassword: service throws -> sets errorMessage")
    func reset_failure_setsError() async {
        let (sut, auth) = makeSUT()
        sut.email = "a@b.com"
        auth.resetPasswordError = TestError.message("network")
        
        await sut.resetPassword()
        
        #expect(auth.resetPasswordCalls == ["a@b.com"])
        #expect(sut.showSuccessAlert == false)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
    }
}
