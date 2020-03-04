//
//  HKData.swift
//  Methodometer
//
//  Created by Alex on 2020-02-26.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import Foundation
import HealthKit

// for watch integration - https://github.com/nhathm/swift_heart_rate_real_time/blob/master/ElecDemo/WorkoutTracking.swift

final class HealthKitManager: ObservableObject {

    static let healthStore = HKHealthStore()
    let workoutConfiguration = HKWorkoutConfiguration()
    var builder: HKWorkoutBuilder?
    var valid = false
    var startDate: Date?
    
    let allHKObjectTypes = Set([
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ])
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health Data is not available!")
            return
        }

        HealthKitManager.healthStore.requestAuthorization(toShare: self.allHKObjectTypes, read: self.allHKObjectTypes) { (success, error) in
            guard success else {
                print("Health Data authorization was rejected!")
                return
            }
        }
        
        workoutConfiguration.activityType = .cycling
        workoutConfiguration.locationType = .indoor
        
        self.valid = true
    }

    func startSession(date: Date) -> Void {
        
        self.builder = HKWorkoutBuilder(
            healthStore: HealthKitManager.healthStore,
            configuration: workoutConfiguration,
            device: .local()
        )
        
        self.startDate = date
        builder!.beginCollection(withStart: self.startDate!) { (success, error) in
            guard success else {
                print("Failed to beginCollection")
                return
            }
        }
    }
    
    func addDistanceSample(_ distance: Double) {
        
        let time = Date()
        let sample = HKCumulativeQuantitySample(
            type: HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            quantity: HKQuantity(unit: HKUnit.mile(), doubleValue: distance),
            start: time,
            end: time
        )
        
        self.builder!.add([sample]) { (success, error) in
            guard success else {
                print("failed to get add")
                return
            }
        }
    }
        
    func finishSession() {

        builder!.endCollection(withEnd: Date()) { (success, error) in
            guard success else {
                print("failed to endCollection")
                return
            }
        }
            
        builder!.finishWorkout { (workout, error) in
            guard workout != nil else {
                print("failed to finishWorkout")
                return
            }
        }
    }
}
