//
//  Workout.swift
//  Methodometer
//
//  Created by Alex on 2020-03-01.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Workout: Identifiable {
    
    static func createDummyWorkout(duration: Double = 3600) -> Workout {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.sampleRate = 1
        workout.dateStarted = Date()
        workout.dateFinished = workout.dateStarted?.addingTimeInterval(duration)
        workout.coachName = [
            "Amanda Chau",
            "Megan Rain",
            "Jamie Lynn",
            "Kelsie Chapman",
            "Jenny Blair",
            "Ben Fogle"
        ].randomElement()
        
        let bikeIDs = uniqueRandoms(numberOfRandoms: Int.random(in: 8...32), range: 1...36)
        let myBikeID = bikeIDs.randomElement()
        
        for i in bikeIDs {
            workout.addToRides(Ride.createDummyRide(duration: duration, myRide: myBikeID == i, bikeID: i))
        }
    
        return workout
    }
    
    var duration: TimeInterval {
        if let df = self.dateFinished {
            return df.timeIntervalSince(self.dateStarted!)
        }
        return Date().timeIntervalSince(self.dateStarted!)
    }
    
    var maxDistance: Double {
        var mD: Double = 0
        for case let ride as Ride in rides!  {
            mD = max(mD, ride.totalDistance)
        }
        return mD
    }
    
    var maxPower: Int {
        var mP: Int = 0
        for case let ride as Ride in rides!  {
            mP = max(mP, ride.maxPower)
        }
        return mP
    }
    
    var minPower: Int {
        var mP: Int = 99999
        for case let ride as Ride in rides!  {
            mP = min(mP, ride.minPower)
        }
        return mP
    }
    
    var maxCadence: Int {
        var mC: Int = 0
        for case let ride as Ride in rides!  {
            mC = max(mC, ride.maxCadence)
        }
        return mC
    }
    
    var minCadence: Int {
        var mC: Int = 99999
        for case let ride as Ride in rides!  {
            mC = min(mC, ride.minCadence)
        }
        return mC
    }
    
    var maxCaloricBurn: Int {
        var mCB: Int = 0
        for case let ride as Ride in rides!  {
            mCB = max(mCB, ride.totalCalories)
        }
        return mCB
    }
    
    var minCaloricBurn: Int {
        var mCB: Int = 99999
        for case let ride as Ride in rides!  {
            mCB = min(mCB, ride.totalCalories)
        }
        return mCB
    }
    
    var hasMyRide: Bool {
        for case let ride as Ride in rides!  {
            if ride.myRide {
                return true
            }
        }
        
        return false
    }
    
    var myRide: Ride {
        for case let ride as Ride in rides!  {
            if ride.myRide {
                return ride
            }
        }
        
        // not the right way...
        return Ride()
    }
    
    var allRides: [Ride] {
        var r = [Ride]()
        for case let ride as Ride in rides! {
            r.append(ride)
        }
        return r.sorted(by: { $0.bikeID < $1.bikeID })
    }
}

extension Ride: Identifiable, Comparable {
    
    static func createDummyRide(
        duration: Double,
        myRide: Bool=false,
        bikeID: Int=Int.random(in: 0...32)
    ) -> Ride {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let ride = Ride(context: context)
        ride.id = UUID()
        ride.dateStarted = Date()
        ride.bikeID = Int16(bikeID)
        ride.elapsedDuration = duration
        ride.elapsedDistance = [Double]()
        ride.gearArray = [Int]()
        ride.cadenceArray = [Int]()
        ride.powerArray = [Int]()
        ride.caloricBurnArray = [Int]()
        ride.myRide = myRide
        ride.createDummyWorkout()
        return ride
    }
    
    private func createDummyWorkout() {
        
        var _elapsedDistance: Double = 0
        var _elapsedCalories: Double = 0

        for _ in 0 ..< 3600 {
            _elapsedDistance += Double.random(in: 0.001...0.009)
            self.elapsedDistance?.append(_elapsedDistance)
            
            _elapsedCalories += Double.random(in: 0.001...0.009)
            self.caloricBurnArray?.append(Int(_elapsedCalories.rounded(.down)))
        }
        
        // START WARMUP - 900 Seconds
        func segment(duration: Double, intervals: Int) {
            
            var remainingTime = duration
            let intervalDuration = duration / Double(intervals)
            
            for _ in 0 ..< intervals {
                remainingTime -= intervalDuration
                let wud = Int(intervalDuration / 100.0 * 20)
                
                self.gearArray! += Array(repeating: Int.random(in: 12...18), count: wud)
                self.cadenceArray! += Array(repeating: Int.random(in: 80...105), count: wud)
                self.powerArray! += Array(repeating: Int.random(in: 120...180), count: wud)
                
                for i in 0...2 {
                    self.gearArray! += Array(repeating: Int.random(in: 12...18) + i, count: wud)
                    self.cadenceArray! += Array(repeating: Int.random(in: 80...115) + i * Int.random(in: 20...40), count: wud)
                    self.powerArray! += Array(repeating: Int.random(in: 120...180) + i * Int.random(in: 20...40), count: wud)
                }
                
                self.gearArray! += Array(repeating: Int.random(in: 8...14), count: wud)
                self.cadenceArray! += Array(repeating: Int.random(in: 70...95), count: wud)
                self.powerArray! += Array(repeating: Int.random(in: 80...120), count: wud)
            }
        }
        
        segment(duration: 900, intervals: 4)
        segment(duration: 900, intervals: 3)
        segment(duration: 900, intervals: 5)
        segment(duration: 900, intervals: 4)

        if (Int(self.elapsedDuration) != self.gearArray!.count) {
            print("WARNING! Duration \(self.elapsedDuration) does not match \(self.gearArray!.count) samples!")
        }
    }
    
    var avgGear: Int {
        let sumArray = self.gearArray!.reduce(0, +)
        return sumArray / self.gearArray!.count
    }
    
    var totalDistance: Double {
        return self.elapsedDistance!.last!
    }
    
    var totalCalories: Int {
        return self.caloricBurnArray!.last!
    }
    
    var maxPower: Int {
        return self.powerArray!.max()!
    }
    
    var minPower: Int {
        return self.powerArray!.min()!
    }
    
    var maxCadence: Int {
        return self.cadenceArray!.max()!
    }
    
    var minCadence: Int {
        return self.cadenceArray!.min()!
    }
    
    public static func ==(lhs: Ride, rhs: Ride) -> Bool {
        return lhs.bikeID == rhs.bikeID
    }
    
    public static func < (lhs: Ride, rhs: Ride) -> Bool {
        lhs.bikeID < rhs.bikeID
    }
}

class SelectedRides: ObservableObject {
    @Published var rides = [Ride]()
}
