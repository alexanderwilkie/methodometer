//
//  Noise.swift
//  Methodometer
//
//  Created by Alex on 2020-03-07.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import UIKit

func uniqueRandoms(numberOfRandoms: Int, range: ClosedRange<Int>) -> [Int] {
    var uniqueNumbers = Set<Int>()
    while uniqueNumbers.count < numberOfRandoms {
        uniqueNumbers.insert(Int.random(in: range))
    }
    return uniqueNumbers.shuffled()
}

func randoms(numberOfRandoms: Int, range: ClosedRange<Int>) -> [Int] {
    var numbers = [Int]()
    while numbers.count < numberOfRandoms {
        numbers.append(Int.random(in: range))
    }
    return numbers
}
