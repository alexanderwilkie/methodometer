//
//  Goal.swift
//  Methodometer
//
//  Created by Alex on 2020-02-22.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation

class Goal: ObservableObject {
    @Published var distance: Float = 20
    @Published var duration: Float = 3600
}
