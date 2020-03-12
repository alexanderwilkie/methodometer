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

public class Perlin1D: NSObject {
    var permutation:[Int] = []

    public init(seed: String) {
        
        let hash = seed.hash
        srand48(hash)
        
        for _ in 0..<512 {
            //Create the permutations to pick from using a seed so you can recreate the map
            permutation.append(Int(drand48() * 255))
        }
    }
    
    func lerp(a:CGFloat, b:CGFloat, x:CGFloat) -> CGFloat {
        return a + x * (b - a) //This interpolates between two points with a weight x
    }
    
    func fade(t:CGFloat) -> CGFloat {
        return t * t * t * (t * (t * 6 - 15) + 10) //This is the smoothing function for Perlin noise
    }
    
    func grad(hash:Int, x:CGFloat) -> CGFloat {
        
        //This takes a hash (a number from 0 - 5) generated from the random permutations and returns a random
        //operation for the node to offset
        
        switch hash & 1 {
        case 0:
            return x
        case 1:
            return -x
        default:
            print("ERROR")
            return 0
        }
    }
    
    func fastfloor(x:CGFloat) -> Int {
        return x > 0 ? Int(x) : Int(x-1)
    }
    
    public func noise(x:CGFloat) -> CGFloat {
        
        //Find the unit grid cell containing the point
        var xi = fastfloor(x: x)
        
        //This is the other bound of the unit square
        let xf:CGFloat = x - CGFloat(xi)
        
        //Wrap the ints around 255
        xi = xi & 255
        
        //These are offset values for interpolation
        let u = fade(t: xf)
        
        //These are the 2 possible permutations so we get the perm value for each
        let a = permutation[xi]
        let b = permutation[xi + 1]
        
        //Lerp a and b
        let ab = lerp(a: grad(hash: a, x: xf), b: grad(hash: b, x: xf - 1), x: u)
        
        //We return the value + 1 / 2 to remove any negatives.
        return (ab + 1) / 2
    }
    
    public func octaveNoise(x:CGFloat, octaves:Int, persistence:CGFloat) -> CGFloat {
        
        //This takes several perlin readings (n octaves) and merges them into one map
        var total:CGFloat = 0
        var frequency: CGFloat = 1
        var amplitude: CGFloat = 1
        var maxValue: CGFloat = 0
        
        //We sum the total and divide by the max at the end to normalise
        for _ in 0 ..< octaves {
            total += noise(x: x * frequency) * amplitude
            
            maxValue += amplitude
            
            //This is taken from recomendations on values
            amplitude *= persistence
            frequency *= 2
        }
                
        return total/maxValue
    }
    
    private func remap(x: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        print(x)
        print(x * (range.upperBound - range.lowerBound) + range.lowerBound)
        return x * (range.upperBound - range.lowerBound) + range.lowerBound
    }
    
    public func octaveArray(width: Int, octaves: Int, persistance: CGFloat, range: ClosedRange<CGFloat>) -> [CGFloat] {
        
        var map:[CGFloat] = []
        
        for x in (0...width) {
            let cx = CGFloat(x)/10
            let p = octaveNoise(x: cx, octaves: octaves, persistence: persistance)
            map.append(remap(x: p, range: range))
        }
        
        return map
    }
}
