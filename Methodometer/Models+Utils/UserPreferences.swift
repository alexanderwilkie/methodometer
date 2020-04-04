//
//  UserPreferences.swift
//  Methodometer
//
//  Created by Alex on 2020-03-30.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation

class UserPreferences: ObservableObject {
    
    static let shared = UserPreferences()
    
    @Published var distanceUnit: DistanceUnit = .miles
    
    private init() {
        self.fromUserDefaults()
    }
    
    func updateUserDefaults() {
        UserDefaults.standard.set(self.distanceUnit.rawValue, forKey: "distanceUnitPref")
    }
    
    func fromUserDefaults() {
        UserDefaults.standard.register(
            defaults: [
                "distanceUnitPref": self.distanceUnit.rawValue
            ]
        )
        
        if let distanceUnitPref = UserDefaults.standard.string(forKey: "distanceUnitPref") {
            self.distanceUnit = DistanceUnit(rawValue: distanceUnitPref)!
        }
    }
}
