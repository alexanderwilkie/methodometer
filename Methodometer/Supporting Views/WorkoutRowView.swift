//
//  WorkoutRowView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-01.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct WorkoutRowView: View {
    var workout: Workout
    
    static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(workout.dateStarted!, formatter: Self.dateFormat) - \(workout.coachName!)")
                
                if (workout.hasMyRide) {
                    HStack {
                        Text("\(workout.myRide.totalDistance) Miles")
                        Text("\(workout.myRide.totalCalories) Cals.")
                        Text("\(workout.rides!.count) bikes")
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return WorkoutRowView(workout: Workout.randomWorkout(context: context))
    }
}
