//
//  Random.swift
//  Methodometer
//
//  Created by Alex on 2020-03-04.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation

func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: Int) -> [Int] {
    var uniqueNumbers = Set<Int>()
    while uniqueNumbers.count < numberOfRandoms {
        uniqueNumbers.insert(Int.random(in: minNum...maxNum))
    }
    return uniqueNumbers.shuffled()
}
