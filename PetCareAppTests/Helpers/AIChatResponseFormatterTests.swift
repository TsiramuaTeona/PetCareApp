//
//  AIChatResponseFormatterTests.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Testing
@testable import PetCareApp

@Suite("AIChatResponseFormatter")
struct AIChatResponseFormatterTests {

    @Test("clean removes markdown bold markers and normalizes bullets/newlines")
    func cleanFormatting() {
        let input = """
        **Hello**
        __World__

        - item one
        * item two

        • already bullet

        
        
        end
        """

        let out = AIChatResponseFormatter.clean(input)

        #expect(out.contains("Hello"))
        #expect(out.contains("World"))
        #expect(out.contains("**") == false)
        #expect(out.contains("__") == false)

        #expect(out.contains("➜ item one"))
        #expect(out.contains("➜ item two"))

        #expect(out.contains("➜ already bullet"))

        #expect(out.contains("\n\n\n") == false)
    }
}
