//
//  FirebaseUserProvider.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 23.01.26.
//

import FirebaseAuth

protocol FirebaseUserProviding {
    var uid: String? { get }
    var email: String? { get }
    var displayName: String? { get }
}

struct FirebaseUserProvider: FirebaseUserProviding {
    var uid: String? { Auth.auth().currentUser?.uid }
    var email: String? { Auth.auth().currentUser?.email }
    var displayName: String? { Auth.auth().currentUser?.displayName }
}
