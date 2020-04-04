//
//  Helpers.swift
//  Methodometer
//
//  Created by Alex on 2020-03-29.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreGraphics

func convertToRange(_ originalValue: CGFloat, from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
    return to.lowerBound + (to.upperBound - to.lowerBound) * (originalValue - from.lowerBound) / (from.upperBound - from.lowerBound)
}


