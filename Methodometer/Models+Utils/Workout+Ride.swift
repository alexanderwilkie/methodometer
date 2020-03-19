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

enum WorkoutStatus: String {
    case notstarted, live, completed, junked
}

extension Workout: Identifiable {
    
    static func createDummyWorkout(duration: Double = 3600, status: WorkoutStatus=WorkoutStatus.completed) -> Workout {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.status = status
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
            workout.addToRides(Ride.createDummyRide(duration: Int16(duration), myRide: myBikeID == i, bikeID: i))
        }
    
        return workout
    }
    
    var status: WorkoutStatus {
        set {
            self.statusString = newValue.rawValue
        }
        get {
            return WorkoutStatus(rawValue: self.statusString!) ?? WorkoutStatus.notstarted // Or whatever the default is
        }

    }
    
    // note this wont work for interuptions or something...
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
    
    var myRide: Ride {
        for case let ride as Ride in rides!  {
            if ride.myRide {
                return ride
            }
        }
        
        // not the right way...
        print("failed to find mybike")
        return Ride(myRide: true, bikeID: 99, duration: 3600)
    }
    
    var allRides: [Ride] {
        var r = [Ride]()
        for case let ride as Ride in rides! {
            r.append(ride)
        }
        return r.sorted(by: { $0.bikeID < $1.bikeID })
    }
    
    func topRides(count: Int = 3) -> [Ride] {
        var r = self.allRides.sorted(by: { $0.totalDistance < $1.totalDistance })[...count]
        if !r.contains(self.myRide)  {
            r = r[...(count-1)]
            r.append(self.myRide)
        }
        return Array(r)
    }
}

extension Ride: Identifiable, Comparable {
    
    convenience init(fromKeiserBike bike: KeiserBike, myRide: Bool) {
        self.init(
            myRide: myRide,
            bikeID: Int16(bike.ordinalId),
            duration: 0,
            initialDistance: bike.tripDistance!,
            initialCaloricBurn: Int16(bike.caloricBurn!)
        )
    }
    
    convenience init(
        myRide: Bool,
        bikeID: Int16,
        duration: Int16=0,
        initialDistance: Double=0,
        initialCaloricBurn: Int16=0
    ) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
        
        self.id = UUID()
        self.dateStarted = Date()
        self.bikeID = bikeID
        self.elapsedDuration = duration
        self.initialDistance = initialDistance
        self.initialCaloricBurn = initialCaloricBurn
        self.elapsedDistanceArray = [Double]([0])
        self.gearArray = [Int]([0])
        self.cadenceArray = [Int]([0])
        self.powerArray = [Int]([0])
        self.caloricBurnArray = [Int]([0])
        self.myRide = myRide
    }
    
    func addSample(fromKeiserBike bike: KeiserBike, atSample: Int16) {
        self.elapsedDuration = atSample
        self.elapsedDistanceArray!.append(bike.tripDistance! - self.initialDistance)
        self.gearArray!.append(bike.gear!)
        self.cadenceArray!.append(bike.cadence!)
        self.powerArray!.append(bike.power!)
        self.caloricBurnArray!.append(bike.caloricBurn! - Int(self.initialCaloricBurn))
    }
    
    func addDroppedSamples(atSample: Int16) {
        self.elapsedDuration = atSample
        self.elapsedDistanceArray!.append(self.elapsedDistanceArray!.last!)
        self.gearArray!.append(self.gearArray!.last!)
        self.cadenceArray!.append(self.cadenceArray!.last!)
        self.powerArray!.append(self.powerArray!.last!)
        self.caloricBurnArray!.append(self.caloricBurnArray!.last!)
    }
    
    static func createDummyRide(
        duration: Int16,
        myRide: Bool=false,
        bikeID: Int=Int.random(in: 0...32)
    ) -> Ride {
        let ride = Ride(myRide: myRide, bikeID: Int16(bikeID), duration: duration)
        ride.createDummyWorkout()
        return ride
    }
    
    private func createDummyWorkout() {
        
        var _elapsedDistance: Double = 0
        var _elapsedCalories: Double = 0

        for _ in 0 ..< 3600 {
            _elapsedDistance += Double.random(in: 0.001...0.009)
            self.elapsedDistanceArray?.append(_elapsedDistance)
            
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
    
    func paceAtSample(sample: Int) -> Double {
        return Double(sample) / 60 / self.elapsedDistanceArray![sample]
    }
    
    var paceArray: [Double] {
        var p = [Double]()
        for i in self.elapsedDistanceArray!.indices {
            p.append(paceAtSample(sample: i))
        }
        return p
    }
    
    var maxPace: Double {
        return self.paceArray.max()!
    }
    
    var minPace: Double {
        return self.paceArray.min()!
    }
    
    var avgPace: Double {
        return Double(self.elapsedDuration) / 60 / self.totalDistance
    }
    
    var maxGear: Int {
        return self.gearArray!.max()!
    }
    
    var minGear: Int {
        return self.gearArray!.min()!
    }
    
    var avgGear: Int {
        let sumArray = self.gearArray!.reduce(0, +)
        return sumArray / self.gearArray!.count
    }
    
    var totalDistance: Double {
        return self.elapsedDistanceArray?.last ?? 0
    }
    
    var totalCalories: Int {
        return self.caloricBurnArray!.last!
    }
    
    var maxPower: Int {
        return self.powerArray!.max()!
    }
    
    var avgPower: Int {
        let sumArray = self.powerArray!.reduce(0, +)
        return sumArray / self.powerArray!.count
    }
    
    var minPower: Int {
        return self.powerArray!.min()!
    }
    
    var maxCadence: Int {
        return self.cadenceArray!.max()!
    }
    
    var avgCadence: Int {
        let sumArray = self.cadenceArray!.reduce(0, +)
        return sumArray / self.cadenceArray!.count
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
    @Published var rides: [Ride]
    
    init(rides: [Ride] = [Ride]()) {
        self.rides = rides
    }
}
