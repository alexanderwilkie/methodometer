//
//  WorkoutRowView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-01.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct WorkoutRowView: View {
    @EnvironmentObject var workout: Workout
    
    static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(workout.dateStarted!, formatter: WorkoutRowView.dateFormat) - \(workout.coachName!)")
                
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
        return WorkoutRowView().environmentObject(Workout.createDummyWorkout())
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
