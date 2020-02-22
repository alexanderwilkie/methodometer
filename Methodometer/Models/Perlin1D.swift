//
//  Perlin1D.swift
//  Methodometer
//
//  Created by Alex on 2020-02-20.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreGraphics
import GameKit

public class Perlin1D: NSObject {
    var permutation:[Int] = []
    
    public init(seed: String) {
        
        let hash = seed.hash
        srand48(hash)
        
        for _ in 0..<512 {
            //Create the permutations to pick from using a seed so you can recreate the map
            permutation.append(Int(Double.random(in: 0...1) * 255))
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
    
    public func perlinArray(width:Int) -> [CGFloat] {
        
        var map:[CGFloat] = []
        for x in (0...width) {
            let cx:CGFloat = CGFloat(x)/50
            let p = noise(x: cx)
            map.append(p)
        }
        
        return map
    }
}
