//
//  Goal.swift
//  Methodometer
//
//  Created by Alex on 2020-02-22.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreData
import os

enum GoalStatus {
    case notstarted, running, finished
}

class Goal: NSObject, ObservableObject {
    @Published var distance: Float = 20
    @Published var duration: Float = 10
    
    @Published var elapsedDistance: Float = 0
    @Published var elapsedDuration: Int = 0

    @Published var targetDistance: Float = 0
    
    @Published var status: GoalStatus = GoalStatus.notstarted
    var bikeDistancesStartOfGoal: [Int:Double] = [:]
    var elapsedDistances: [Int:Double] = [:]
    
    let hkm = HealthKitManager()
    
    var kbm: KeiserBikeManager?
    
    func onTarget() -> Bool {
        return (Int(self.elapsedDistance * 100)) >= Int((self.targetDistance * 100))
    }

    func startWorkout(context: NSManagedObjectContext, workout: Workout, myBikeID: Int, kbm: KeiserBikeManager) {
        
        print("[DEBUG] [Goal:startWorkout] distance: \(self.distance). duration: \(self.duration)")
        
        self.kbm = kbm
        self.status = GoalStatus.running
        //hkm.startSession(date: Date())
        
        let t = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true) { timer in
            if self.elapsedDuration <= Int(0) {
                for (bikeID, bike) in self.kbm!.foundBikes {
                    self.bikeDistancesStartOfGoal[bikeID] = bike.tripDistance
                }
            }
            
            self.elapsedDuration += 1
            
            for (bikeID, bike) in self.kbm!.foundBikes {
                
                //let p = self.elapsedDistances[bikeID]
                self.elapsedDistances[bikeID] = bike.tripDistance! - self.bikeDistancesStartOfGoal[bikeID]!
                
                //print("[DEBUG] [Goal:start:addDistanceSample]: adding sample: \(self.elapsedDistance - p)")
                //self.hkm.addDistanceSample(Double(self.elapsedDistance - p))
                
                self.targetDistance += self.distance / self.duration
            }
            
            if self.elapsedDuration >= Int(self.duration) {
                self.status = GoalStatus.finished
                for (bikeID, bike) in self.kbm!.foundBikes {
                    let ride = Ride(context: context)
                    if bikeID == myBikeID {
                        ride.myRide = true
                    }
                    ride.bikeID = Int16(bikeID)
                    ride.totalDistance = self.elapsedDistances[bikeID]!
                    //ride.totalCalories = Int16.random(in: 400...700)
                    workout.addToRides(ride)
                }
                //self.hkm.finishSession()
                do {
                    try context.save()
                } catch {
                    print("Invalid Selection.")
                }
                
                timer.invalidate()
            }
        }
        RunLoop.main.add(t, forMode: .common)
    }
}
