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
    
    static let shortDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    static let shortTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        HStack {
            if (workout.managedObjectContext == nil) {
                EmptyView()
            } else {
                VStack(alignment: .leading) {
                    Text("\(workout.dateStarted!, formatter: WorkoutRowView.shortDateFormat)")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(workout.dateStarted!, formatter: WorkoutRowView.shortTimeFormat)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Divider()
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(workout.coachName!)")
                            .font(.subheadline)
                            .fontWeight(.light)
                        Text("\(workout.myRide.totalDistance, specifier: "%02.2f") Miles.")
                            .font(.subheadline)
                            .fontWeight(.light)
                    }
                    HStack {
                        Text("\(workout.myRide.elapsedDuration / 60, specifier: "%02.0f") Mins @ \(workout.myRide.avgPace, specifier: "%02.2f")/m Avg Pace.")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                Spacer()
            }
        }.padding()
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        return WorkoutRowView().environmentObject(
            Workout.createDummyWorkout()
        )
            .previewLayout(.fixed(width: 375, height: 70))
    }
}
