//
//  FirebaseUserProviderMock.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import Foundation
@testable import PetCareApp

struct FirebaseUserProviderMock: FirebaseUserProviding {
    var uid: String? = "mockUID"
    var email: String?
    var displayName: String?
}
