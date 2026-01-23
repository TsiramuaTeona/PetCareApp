//
//  FieldValidatorTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Testing
@testable import PetCareApp

@Suite("FieldValidator")
struct FieldValidatorTests {

    // MARK: - required

    @Test("required returns .required for empty/whitespace")
    func required_empty() {
        #expect(FieldValidator.required("") == .required)
        #expect(FieldValidator.required("   ") == .required)
        #expect(FieldValidator.required("\n\t") == .required)
    }

    @Test("required returns nil for non-empty")
    func required_nonEmpty() {
        #expect(FieldValidator.required("a") == nil)
        #expect(FieldValidator.required("  a  ") == nil)
    }

    // MARK: - email

    @Test("email returns .required for empty/whitespace")
    func email_required() {
        #expect(FieldValidator.email("") == .required)
        #expect(FieldValidator.email("   ") == .required)
        #expect(FieldValidator.email("\n") == .required)
    }

    @Test("email returns nil for valid emails (simple pattern)")
    func email_valid() {
        #expect(FieldValidator.email("a@b.co") == nil)
        #expect(FieldValidator.email("user.name@domain.com") == nil)
        #expect(FieldValidator.email("user+tag@domain.com") == nil)
        #expect(FieldValidator.email("x@y.z") == nil)
    }

    @Test("email returns .invalidEmail for invalid emails")
    func email_invalid() {
        #expect(FieldValidator.email("plain") == .invalidEmail)
        #expect(FieldValidator.email("a@b") == .invalidEmail)
        #expect(FieldValidator.email("a@b.") == .invalidEmail)
        #expect(FieldValidator.email("@b.com") == .invalidEmail)
        #expect(FieldValidator.email("a@.com") == .invalidEmail)
        #expect(FieldValidator.email("a b@c.com") == .invalidEmail)
    }

    @Test("email trims before regex (leading/trailing spaces should pass)")
    func email_spacesAround_passes() {
        #expect(FieldValidator.email(" a@b.co ") == nil)
        #expect(FieldValidator.email("\n\tuser@domain.com  ") == nil)
    }
    
    @Test("email with internal spaces is invalid")
    func email_internalSpaces_fails() {
        #expect(FieldValidator.email("a b@c.com") == .invalidEmail)
    }

    // MARK: - password

    @Test("password returns .required for empty/whitespace")
    func password_required() {
        #expect(FieldValidator.password("") == .required)
        #expect(FieldValidator.password("   ") == .required)
    }

    @Test("password returns nil for strong password")
    func password_valid() {
        #expect(FieldValidator.password("Abcdefg1") == nil)
        #expect(FieldValidator.password("XyZ12345a") == nil)
    }

    @Test("password returns .weakPassword when missing requirements")
    func password_weak() {
        #expect(FieldValidator.password("abcdefg1") == .weakPassword)
        #expect(FieldValidator.password("ABCDEFG1") == .weakPassword)
        #expect(FieldValidator.password("Abcdefgh") == .weakPassword)
        #expect(FieldValidator.password("Abc1") == .weakPassword)
    }

    // MARK: - confirmPassword

    @Test("confirmPassword returns .required for empty/whitespace")
    func confirmPassword_required() {
        #expect(FieldValidator.confirmPassword("", password: "Abcdefg1") == .required)
        #expect(FieldValidator.confirmPassword("   ", password: "Abcdefg1") == .required)
    }

    @Test("confirmPassword returns nil when matches")
    func confirmPassword_matches() {
        #expect(FieldValidator.confirmPassword("Abcdefg1", password: "Abcdefg1") == nil)
    }

    @Test("confirmPassword returns .passwordsDontMatch when different")
    func confirmPassword_notMatch() {
        #expect(FieldValidator.confirmPassword("Abcdefg1", password: "Abcdefg2") == .passwordsDontMatch)
        #expect(FieldValidator.confirmPassword("abc", password: "abc ") == .passwordsDontMatch)
    }
}
