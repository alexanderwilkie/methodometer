//
//  Time.swift
//  Methodometer
//
//  Created by Alex on 2020-02-23.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation

func secondsToMinutes(_ seconds: Int) -> Int {
    return Int(seconds / 60)
}

func secondsToMinutes(_ seconds: Float) -> Int {
    return Int(Int(seconds) / 60)
}

public func secondsToString(_ seconds: Int) -> String {
    return String(format: "%02d:%02d", secondsToMinutes(seconds), seconds - secondsToMinutes(seconds) * 60)
}
