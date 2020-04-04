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
        formatter.dateFormat = "HH:mm"
        
        return formatter
    }()
    private static let ampmFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "a"
        
        return formatter
    }()

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                if (self.workout.managedObjectContext == nil) {
                    EmptyView()
                } else {
                    VStack(spacing: 5) {
                        HStack(alignment: .lastTextBaseline) {
                            VStack(alignment: .leading) {
                                Text("\(self.workout.dateStarted!, formatter: WorkoutRowView.shortTimeFormat)")
                                            .modifier(H3())
                                Text("\(self.workout.dateStarted!, formatter: WorkoutRowView.shortDateFormat)")
                                    .modifier(Label())
                            }
                            VStack(alignment: .leading) {
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text("\(Int(self.workout.duration / 60))")
                                        .modifier(H3())
                                    Text("Mins")
                                        .modifier(H4())
                                }
                                Text("Duration")
                                    .modifier(Label())
                            }
                            Spacer()
                            Text(self.isDistancePB ? "🏆" : "")
                                .font(Font.system(size: 26.0))
                                .offset(x: 10, y: -4)
                            Text(rankToEmoji(self.workout.getRank(self.workout.myRide)))
                                .font(Font.system(size: 26.0))
                                .offset(y: -4)
                            
                            VStack(alignment: .trailing) {
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    DistanceText(d: self.workout.myRide.totalDistance)
                                        .modifier(H3())
                                    DistanceUnitText()
                                        .modifier(H4())
                                }
                                Text("Distance")
                                    .modifier(Label())
                            }
                        }
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text("\(self.workout.coachName!)")
                                    .modifier(H4())
                                Text("Coach")
                                    .modifier(Label())
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                HStack(alignment: .lastTextBaseline, spacing: 0) {
                                    Text("\(self.workout.getRank(self.workout.myRide))")
                                        .modifier(H4())
                                    Text(toOrdinal(self.workout.getRank(self.workout.myRide)))
                                        .modifier(H5())
                                }
                                Text("Rank")
                                    .modifier(Label())
                            }
                            VStack(alignment: .trailing) {
                                Text("\(self.workout.myRide.bikeID)")
                                    .modifier(H4())
                                Text("Bike")
                                    .modifier(Label())
                            }
                        }
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("\(self.workout.myRide.avgCadence)/\(self.workout.myRide.maxCadence) RPM")
                                    .modifier(H4())
                                Text("AVG/Max Cadence")
                                    .modifier(Label())
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(self.workout.myRide.avgPower)/\(self.workout.myRide.maxPower) Watts")
                                    .modifier(H4())
                                Text("AVG/Max Power")
                                    .modifier(Label())
                            }
                        }.padding(.bottom, 5)
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("\(self.workout.myRide.avgGear)/\(self.workout.myRide.maxGear)")
                                    .modifier(H4())
                                Text("AVG/Max Gear")
                                    .modifier(Label())
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                PaceText(p: [self.workout.myRide.avgPace, self.workout.myRide.maxPace])
                                Text("AVG/Max Pace")
                                    .modifier(Label())
                            }
                        }.padding(.bottom, 5)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 5)
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
