//
//  StringExtensionsTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Testing
@testable import PetCareApp

@Suite("String+Extensions")
struct StringExtensionsTests {

    @Test("doubleValue parses comma decimal")
    func doubleValueComma() {
        let value = "12,5".doubleValue
        #expect(value != nil)
        #expect(abs((value ?? 0) - 12.5) < 0.0001)
    }

    @Test("doubleValue parses dot decimal")
    func doubleValueDot() {
        let value = "3.14".doubleValue
        #expect(value != nil)
        #expect(abs((value ?? 0) - 3.14) < 0.0001)
    }

    @Test("trimmed removes surrounding whitespace/newlines")
    func trimmed() {
        #expect("  hi \n".trimmed == "hi")
    }

    @Test("nilIfEmpty returns nil only for empty string")
    func nilIfEmpty() {
        #expect("".nilIfEmpty == nil)
        #expect("a".nilIfEmpty == "a")
    }

    @Test("isEmptyOrWhitespace detects whitespace-only")
    func emptyOrWhitespace() {
        #expect("   \n\t ".isEmptyOrWhitespace == true)
        #expect(" x ".isEmptyOrWhitespace == false)
    }

    @Test("normalize trims, collapses spaces, lowercases")
    func normalize() {
        #expect("  Hello   WORLD  ".normalize == "hello world")
        #expect("A\t\tB\nC".normalize == "a b c")
    }
}
