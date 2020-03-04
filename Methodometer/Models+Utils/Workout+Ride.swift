//
//  Workout.swift
//  Methodometer
//
//  Created by Alex on 2020-03-01.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import CoreData

extension Workout: Identifiable {
    
    static func createWorkout(context: NSManagedObjectContext, dateStarted: Date, coachName: String) -> Workout {
        let workout = Workout(context: context)
        
        workout.id = UUID()
        workout.dateStarted = dateStarted
        workout.coachName = coachName
        
        return workout
    }
    
    static func randomWorkout(context: NSManagedObjectContext) -> Workout {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.dateStarted = Date()
        workout.coachName = "Amanda"
        
        let ride = Ride.randomRide(context: context, myRide: true, bikeID: Int16.random(in: 1...4))
        workout.addToRides(ride)
        
        for bikeID in uniqueRandoms(numberOfRandoms: Int.random(in: 5...32), minNum: 5, maxNum: 36) {
            let r = Ride.randomRide(context: context, myRide: false, bikeID: Int16(bikeID))
            workout.addToRides(r)
        }
        
        return workout
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
}

extension Ride: Identifiable {
    static func randomRide(context: NSManagedObjectContext, myRide: Bool, bikeID: Int16) -> Ride {
        let ride = Ride(context: context)
        ride.myRide = myRide
        ride.bikeID = bikeID
        ride.totalDistance = Double.random(in: 16...22)
        ride.totalCalories = Int16.random(in: 400...700)
        ride.gear = [1,3,3,4,4,5,5,5,5]
        return ride
    }
}
