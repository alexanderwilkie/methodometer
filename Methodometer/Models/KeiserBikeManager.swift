//
//  KeiserBikeManager.swift
//  Methodometer
//
//  Created by Alex on 2020-02-18.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation

class KeiserBikeManager: NSObject, Identifiable, ObservableObject {
    var bleDelegate = BLEManagerDelegate()
    
    var availableBikes: [KeiserBike] {
        return []
    }
}
