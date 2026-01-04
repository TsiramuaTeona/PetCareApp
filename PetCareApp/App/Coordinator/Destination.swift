//
//  Destination.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


enum Destination {
    case login
    case register
    case resetPassword

    case mainTabs
    
    case selectTab(MainTab)
    
    case petDetails(petId: String)
    case scanner(onScan: (String) -> Void)
}
