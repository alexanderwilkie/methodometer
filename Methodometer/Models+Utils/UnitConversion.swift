//
//  UnitConversion.swift
//  Methodometer
//
//  Created by Alex on 2020-03-31.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation

enum DistanceUnit: String {
    case miles, kilometers
}

func distanceForUnit(_ distance: Double, unit: DistanceUnit) -> Double {
    if unit == .kilometers {
        return distance * 1.609344
    }
    return distance
}

func paceForUnit(_ pace: Double, unit: DistanceUnit) -> Double {
    if unit == .kilometers {
        return pace * (1 / 1.609344)
    }
    return pace
}

func toOrdinal(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    let ordinal = formatter.string(from: NSNumber(value: number))!
    return String(ordinal.suffix(2))
}

func secondsToMinutes(_ seconds: Int) -> Int {
    return Int(seconds / 60)
}

func secondsToMinutes(_ seconds: Float) -> Int {
    return secondsToMinutes(Int(seconds))
}

public func secondsToString(_ seconds: Int) -> String {
    return String(format: "%02d:%02d", secondsToMinutes(seconds), seconds - secondsToMinutes(seconds) * 60)
}
