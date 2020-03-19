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

enum SessionStatus {
    case notstarted, running, finished
}

class Session: NSObject, ObservableObject {
    @Published var distance: Float = 20
    @Published var duration: Float = 3600
    @Published var elapsedDistance: Float = 0
    @Published var elapsedDuration: Int = 0
    @Published var targetDistance: Float = 0
    @Published var status: SessionStatus = .notstarted
    
    var rides: [Int:Ride] = [:]

    let hkm = HealthKitManager()
    
    var timer: Timer?
    var kbm: KeiserBikeManager?
    var workout: Workout?
    var myBikeID: Int?
    
    func reset() {
        self.status = .notstarted
        self.elapsedDuration = 0
        self.workout = nil
        self.myBikeID = nil
        self.rides = [:]
        if let _ = self.timer?.isValid {
            self.timer?.invalidate()
        }
    }
    
    func configure(coachName: String, myBikeID: Int, kbm: KeiserBikeManager) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        self.kbm = kbm
        self.myBikeID = myBikeID

        self.workout = Workout(context: context)
        self.workout!.id = UUID()
        self.workout!.status = WorkoutStatus.notstarted
        self.workout!.coachName = coachName
        self.workout!.sampleRate = 1
        
        do {
            print("[DEBUG] [Session:stopWorkout] Saving workout for \(self.kbm!.foundBikes.count) bikes!")
            try context.save()
        } catch {
            print("Invalid Selection.")
        }
    }
    
    func configureFromWorkout(fromWorkout workout: Workout, kbm: KeiserBikeManager) {
        self.kbm = kbm
        self.workout = workout
        
        self.elapsedDuration = Int(abs((self.workout?.dateStarted!.timeIntervalSince(Date())) ?? 0))
        let timeDiff = Int16(self.elapsedDuration) - (self.workout?.myRide.elapsedDuration ?? 0)
        print("Resuming workout! Last contat was \(timeDiff) seconds ago... filling in the blanks, then restarting!")
        for ride in workout.allRides {
            let bikeID = Int(ride.bikeID)
            if (ride.myRide) {
                self.myBikeID = bikeID
            }
            if (self.rides.index(forKey: bikeID) == nil) {
                self.rides[bikeID] = ride
            }
            
            for i in (self.workout?.myRide.elapsedDuration ?? 0)...(self.workout?.myRide.elapsedDuration ?? 0)+timeDiff {
                print(self.elapsedDuration)
                print(i)
                self.rides[bikeID]!.addDroppedSamples(atSample: i)
            }
        }
        

        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(sampleSession), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    static func fakeSession() -> Session {
        let kbm = KeiserBikeManager(simulated: true)
        let session = Session()
        session.configure(coachName: "Amanda", myBikeID: kbm.foundBikes.first!.value.ordinalId, kbm: kbm)
        session.startSession()
        return session
    }
    
    func onTarget() -> Bool {
        return (Int(self.elapsedDistance * 100)) >= Int((self.targetDistance * 100))
    }

    func startSession() {
        print("[DEBUG] [Session:startSession] Starting session at: \(Date())")
        self.status = .running

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.workout!.status = WorkoutStatus.live
        self.workout!.dateStarted = Date()
        self.initialiseBikes()

        //hkm.startSession(date: Date())
                
        do {
            print("[DEBUG] [Session:stopWorkout] Saving workout for \(self.kbm!.foundBikes.count) bikes!")
            try context.save()
        } catch {
            print("Invalid Selection.")
        }
        
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(sampleSession), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    func initialiseBikes() {
        for (bikeID, bike) in self.kbm!.foundBikes {
            if (self.rides.index(forKey: bikeID) == nil) {
                self.rides[bikeID] = Ride(fromKeiserBike: bike, myRide: bikeID == self.myBikeID)
                self.workout!.addToRides(self.rides[bikeID]!)
            }
        }
    }
        
    @objc func sampleSession(interval: TimeInterval = 1) {
        print("[DEBUG] [Session:sampleSession] Sampling session at: \(self.elapsedDuration) into session")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // run each sample to check for new bikes joining
        self.initialiseBikes()
        
        self.elapsedDuration += Int(self.timer!.timeInterval)
        context.performAndWait {
            for (bikeID, bike) in self.kbm!.foundBikes {
                self.rides[bikeID]!.addSample(fromKeiserBike: bike, atSample: Int16(self.elapsedDuration))

                // self.hkm.addDistanceSample(Double(self.elapsedDistance - p))
                self.targetDistance += self.distance / self.duration
            }
            
            try? context.save()
        }
        
        if self.elapsedDuration >= Int(self.duration) {
            stopSession()
        }
    }
    
    func stopSession() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.status = .finished
        workout!.status = WorkoutStatus.completed
        workout!.dateFinished = Date()

        for (bikeID, _) in self.kbm!.foundBikes {
            print("[DEBUG] [Session:stopWorkout] Adding Ride for bike: \(bikeID) at end of session")
            if (self.rides.index(forKey: bikeID) != nil) {
                workout!.addToRides(self.rides[bikeID]!)
            } else {
                print("Couldn't find bike \(bikeID) in rides?!")
            }
        }
        //self.hkm.finishSession()
        do {
            print("[DEBUG] [Session:stopWorkout] Saving workout for \(self.kbm!.foundBikes.count) bikes!")
            try context.save()
        } catch {
            print("Invalid Selection.")
        }
        
        if let _ = self.timer?.isValid {
            print("Stopping timer")
            self.timer?.invalidate()
        } else {
            print("Couldn't stop timer!")
        }
    }
}
