//
//  Goal.swift
//  Methodometer
//
//  Created by Alex on 2020-02-22.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import os

enum GoalStatus {
    case notstarted, running, finished
}

class Session: NSObject, ObservableObject {
    @Published var distance: Float = 20
    @Published var duration: Float = 10
    @Published var elapsedDistance: Float = 0
    @Published var elapsedDuration: Int = 0
    @Published var targetDistance: Float = 0
    @Published var status: GoalStatus = GoalStatus.notstarted
    
    var initialCaloricBurns: [Int:Int] = [:]
    var initialDistances: [Int:Double] = [:]
    
    var rides: [Int:Ride] = [:]

    let hkm = HealthKitManager()
    
    var timer: Timer?
    var kbm: KeiserBikeManager?
    var workout: Workout?
    var myBikeID: Int?
    
    static func fakeSession() -> Session {
        let start = CFAbsoluteTimeGetCurrent()
        let session = Session()
        let kbm = KeiserBikeManager(simulated: true)
        session.startSession(coachName: "Amanda", myBikeID: kbm.foundBikes.first!.value.ordinalId, kbm: kbm, live: false)
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Took \(diff) seconds to generate sessions")
        
        return session
    }
    
    func onTarget() -> Bool {
        return (Int(self.elapsedDistance * 100)) >= Int((self.targetDistance * 100))
    }

    func startSession(coachName: String, myBikeID: Int, kbm: KeiserBikeManager, live: Bool = false) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        self.kbm = kbm
        self.status = GoalStatus.running
        
        self.workout = Workout(context: context)
        self.workout!.id = UUID()
        self.workout!.dateStarted = Date()
        self.workout!.coachName = coachName
        
        self.myBikeID = myBikeID
        
        //hkm.startSession(date: Date())
        
        if live {
            self.workout!.sampleRate = 1
            self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(sampleSession), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer!, forMode: .common)
        } else {
            self.workout!.sampleRate = 60
            for _ in stride(from: 0, to: Int(self.duration), by: 60) {
                sampleSession(interval: 60)
            }
        }
    }
        
    @objc func sampleSession(interval: TimeInterval = 1) {
        print("[DEBUG] [Session:sampleSession] Sampling session at: \(self.elapsedDuration) into session")

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for (bikeID, bike) in self.kbm!.foundBikes {
            if (self.initialDistances.index(forKey: bikeID) == nil) {
                print("[DEBUG] [Session:sampleSession] Creating intitial Ride for session on bike: \(bikeID) - my bike is \(self.myBikeID)")

                // need a better idea of cumilitive samples or something for the data that accumlate over time
                self.initialDistances[bikeID] = bike.tripDistance
                self.initialCaloricBurns[bikeID] = bike.caloricBurn

                let ride = Ride(context: context)
                ride.id = UUID()
                ride.dateStarted = Date()
                ride.bikeID = Int16(bikeID)
                ride.elapsedDistance = [Double]()
                ride.gearArray = [Int]()
                ride.cadenceArray = [Int]()
                ride.powerArray = [Int]()
                ride.caloricBurnArray = [Int]()
                if bikeID == self.myBikeID {
                    ride.myRide = true
                }
                self.rides[bikeID] = ride
            }
        }
        
        var i = interval
        if let _  = self.timer?.isValid {
            i = self.timer!.timeInterval
        }
        self.elapsedDuration += Int(i)
                    
        for (bikeID, bike) in self.kbm!.foundBikes {
            self.rides[bikeID]!.elapsedDistance!.append(bike.tripDistance! - self.initialDistances[bikeID]!)
            self.rides[bikeID]!.gearArray!.append(bike.gear!)
            self.rides[bikeID]!.cadenceArray!.append(bike.cadence!)
            self.rides[bikeID]!.powerArray!.append(bike.power!)
            self.rides[bikeID]!.caloricBurnArray!.append(bike.caloricBurn! - self.initialCaloricBurns[bikeID]!)
            //self.hkm.addDistanceSample(Double(self.elapsedDistance - p))
            
            self.targetDistance += self.distance / self.duration
        }
        
        if self.elapsedDuration >= Int(self.duration) {
            stopWorkout()
        }
    }
    
    func stopWorkout() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        self.status = GoalStatus.finished
        
        // set the end date to now if we using timer... if not set fake
        if let _  = self.timer?.isValid {
            print("[DEBUG] [Session:stopWorkout] Storing end of workout to be now")
            workout!.dateFinished = Date()
        } else {
            print("[DEBUG] [Session:stopWorkout] Storing end of workout to be \(self.duration)")
            workout!.dateFinished = workout?.dateStarted?.addingTimeInterval(TimeInterval(self.duration))
        }
        
        for (bikeID, _) in self.kbm!.foundBikes {
            print("[DEBUG] [Session:stopWorkout] Adding Ride for bike: \(bikeID) at end of session")
            workout!.addToRides(self.rides[bikeID]!)
        }
        //self.hkm.finishSession()
        do {
            print("[DEBUG] [Session:stopWorkout] Saving workout for \(self.kbm!.foundBikes.count) bikes!")
            try context.save()
        } catch {
            print("Invalid Selection.")
        }
        
        self.kbm!.stopFakeSession()
        if let _ = self.timer?.isValid {
            self.timer?.invalidate()
        }
    }
}
