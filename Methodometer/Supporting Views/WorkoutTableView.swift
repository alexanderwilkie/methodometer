//
//  WorkoutTableView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-22.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct WorkoutTableView: View {
    @EnvironmentObject var workout: Workout
    @State var sortBy: Int = 1
    
    private let rowHeight: CGFloat = 40
    
    private var columnHeadings: [String] {
        return ["Bike", "Rank", "Miles", "AVG\nPace", "AVG\nCadence", "AVG\nPower"]
    }
    
    private var sortedRides: [Ride] {

        if self.sortBy == 1 {
            return self.workout.allRides.sorted(by: { $0.bikeID < $1.bikeID })
        } else if self.sortBy == -1 {
            return self.workout.allRides.sorted(by: { $0.bikeID > $1.bikeID })
        }
            
        if self.sortBy == 2 {
            return self.workout.allRides.sorted(by: { self.workout.getRank($0) < self.workout.getRank($1) })
        } else if self.sortBy == -2 {
            return self.workout.allRides.sorted(by: { self.workout.getRank($0) > self.workout.getRank($1) })
        }
        
        if self.sortBy == 3 {
            return self.workout.allRides.sorted(by: { $0.totalDistance < $1.totalDistance })
        } else if self.sortBy == -3 {
            return self.workout.allRides.sorted(by: { $0.totalDistance > $1.totalDistance })
        }
        
        if self.sortBy == 4 {
            return self.workout.allRides.sorted(by: { $0.avgPace < $1.avgPace })
        } else if self.sortBy == -4 {
            return self.workout.allRides.sorted(by: { $0.avgPace > $1.avgPace })
        }
        
        if self.sortBy == 5 {
            return self.workout.allRides.sorted(by: { $0.avgCadence < $1.avgCadence })
        } else if self.sortBy == -5 {
            return self.workout.allRides.sorted(by: { $0.avgCadence > $1.avgCadence })
        }
        
        if self.sortBy == 6 {
            return self.workout.allRides.sorted(by: { $0.avgPower < $1.avgPower })
        } else if self.sortBy == -6 {
            return self.workout.allRides.sorted(by: { $0.avgPower > $1.avgPower })
        }
        
        return self.workout.allRides
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(self.columnHeadings.indices, id: \.self) { i in
                        ZStack {
                            HStack(spacing: 0) {
                                Text(self.columnHeadings[i])
                                    .modifier(Label(color: Color.white))
                                    .multilineTextAlignment(.center)
                                    .frame(width: geometry.size.width / CGFloat(self.columnHeadings.count))
                                    .onTapGesture {
                                        if abs(self.sortBy) == i + 1 {
                                            self.sortBy.negate()
                                        } else {
                                            self.sortBy = i + 1
                                        }
                                    }
                                Divider()
                            }
                            if abs(self.sortBy) == i + 1 {
                                Image(systemName: self.sortBy.signum() > 0 ? "arrowtriangle.down.circle" : "arrowtriangle.up.circle")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .offset(x: -20, y: 0)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: self.rowHeight)
                .border(Color.gray)
                .foregroundColor(Color.white)
                .background(Color.gray)
                
                List {
                    ForEach(self.sortedRides) { ride in
                        HStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("\(ride.bikeID, specifier: "%02d")")
                                .modifier(H4())
                                .frame(
                                    width: geometry.size.width / CGFloat(self.columnHeadings.count),
                                    height: self.rowHeight
                                )
                                Divider()
                            }
                            HStack(spacing: 0) {
                                Text("\(self.workout.getRank(ride))")
                                .modifier(H4())
                                .frame(
                                    width: geometry.size.width / CGFloat(self.columnHeadings.count),
                                    height: self.rowHeight
                                )
                                Divider()
                            }
                            HStack(spacing: 0) {
                                Text("\(ride.totalDistance, specifier: "%02.2f")")
                                .modifier(H4())
                                .frame(
                                    width: geometry.size.width / CGFloat(self.columnHeadings.count),
                                    height: self.rowHeight
                                )
                                Divider()
                            }
                            HStack(spacing: 0) {
                                Text("\(ride.avgPace, specifier: "%02.2f")/m")
                                .modifier(H4())
                                .frame(
                                    width: geometry.size.width / CGFloat(self.columnHeadings.count),
                                    height: self.rowHeight
                                )
                                Divider()
                            }
                            HStack(spacing: 0) {
                                Text("\(ride.avgCadence)")
                                .modifier(H4())
                                .frame(
                                    width: geometry.size.width / CGFloat(self.columnHeadings.count),
                                    height: self.rowHeight
                                )
                                Divider()
                            }
                            HStack(spacing: 0) {
                                Text("\(ride.avgPower)")
                                .modifier(H4())
                                .frame(
                                    width: geometry.size.width / CGFloat(self.columnHeadings.count),
                                    height: self.rowHeight
                                )
                            }
                        }
                        .frame(width: geometry.size.width, height: self.rowHeight)
                        .foregroundColor(colorForRide(ride))
                    }.listRowInsets(EdgeInsets())
                }
                .environment(\.defaultMinListRowHeight, self.rowHeight)
                .onAppear() {
                    UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
            }
        }
    }
}

struct WorkoutTableView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTableView()
            .environmentObject(Workout.createDummyWorkout(duration: 3600))
    }
}
