//
//  WorkoutRowView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-01.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct WorkoutRowView: View {
    var isDistancePB: Bool = false
    @EnvironmentObject var workout: Workout
    
    private static let shortDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    private static let shortTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm a"
        
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                if (self.workout.managedObjectContext == nil) {
                    EmptyView()
                } else {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .trailing) {
                            Text("\(self.workout.dateStarted!, formatter: WorkoutRowView.shortTimeFormat)")
                                    .modifier(H4())
                            Text("\(self.workout.dateStarted!, formatter: WorkoutRowView.shortDateFormat)")
                                .modifier(Label())
                        }
                    }
                    .padding(.bottom, 5)
                    .frame(width: geometry.size.width / 4, alignment: .trailing)
                    
                    Divider()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text("\(self.workout.myRide.totalDistance, specifier: "%02.2f") Miles")
                                .modifier(H4())
                            Text("\(secondsToString(Int(self.workout.duration))) @ \(self.workout.myRide.avgPace, specifier: "%02.2f")/m Avg Pace.")
                            .modifier(Label())
                        }
                    }
                    .padding(.bottom, 5)
                    .frame(width: geometry.size.width / 2.45, alignment: .leading)

                    Divider()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text("\(self.workout.getRank(self.workout.myRide))")
                                .modifier(H4())
                            Text("Rank")
                                .modifier(Label())
                        }
                        Text(rankToEmoji(self.workout.getRank(self.workout.myRide)))
                            .padding(.horizontal, -5)
                            .modifier(Emoji())
                            .offset(x: 0, y: 3)
                        Text(self.isDistancePB ? "🏆" : "")
                            .padding(.horizontal, -5)
                            .modifier(Emoji())
                            .offset(x: 0, y: 2.5)
                        
                        Spacer()
                    }.padding(.bottom, 5)
                }
            }
            .frame(height: 75)
        }
    }
}

struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        return WorkoutRowView(isDistancePB: true).environmentObject(
            Workout.createDummyWorkout()
        )
    }
}
