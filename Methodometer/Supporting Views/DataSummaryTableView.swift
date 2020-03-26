//
//  DataSummaryTableView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-21.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

enum DataType: String, CaseIterable {
    case gear, pace, distance, power, cadence
}

struct DataSummaryTableView: View {
    @EnvironmentObject var selectedRides: SelectedRides
    @EnvironmentObject var workout: Workout

    var dataType: DataType
    var sectionWidth: CGFloat = 400

    var body: some View {
        return HStack(spacing: 0) {
            ForEach(self.selectedRides.rides) { ride in
                VStack(alignment: .center) {
                    Text("\(ride.bikeID) | \(self.workout.getRank(ride))")
                        .modifier(H4())
                    Text("Bike | Rank")
                        .modifier(Label())
                    Divider()
                    if self.dataType == .gear {
                        Text("\(ride.maxGear)")
                            .modifier(H4())
                        Text("Max")
                            .modifier(Label())
                        Divider()
                        Text("\(ride.avgGear)")
                            .modifier(H4())
                        Text("AVG")
                            .modifier(Label())
                        Divider()
                        Text("\(ride.minGear)")
                            .modifier(H4())
                        Text("Min")
                            .modifier(Label())
                    } else if self.dataType == .pace {
                        Text("\(ride.maxPace, specifier: "%02.2f")/m")
                            .modifier(H4())
                        Text("Max")
                            .modifier(Label())
                        Divider()
                        Text("\(ride.avgPace, specifier: "%02.2f")/m")
                            .modifier(H4())
                        Text("AVG")
                            .modifier(Label())
                        Divider()
                        Text("\(ride.minPace, specifier: "%02.2f")/m")
                            .modifier(H4())
                        Text("Max")
                            .modifier(Label())
                    } else if self.dataType == .distance {
                       Text("\(ride.totalDistance, specifier: "%02.2f")")
                           .modifier(H4())
                       Text("Distance")
                           .modifier(Label())
                    } else if self.dataType == .power {
                       Text("\(ride.maxPower)")
                           .modifier(H4())
                       Text("Max")
                           .modifier(Label())
                       Divider()
                       Text("\(ride.avgPower)")
                           .modifier(H4())
                       Text("AVG")
                           .modifier(Label())
                       Divider()
                       Text("\(ride.minPower)")
                           .modifier(H4())
                       Text("Min")
                           .modifier(Label())
                    } else if self.dataType == .cadence {
                       Text("\(ride.maxCadence)")
                           .modifier(H4())
                       Text("Max")
                           .modifier(Label())
                       Divider()
                       Text("\(ride.avgCadence)")
                           .modifier(H4())
                       Text("AVG")
                           .modifier(Label())
                       Divider()
                       Text("\(ride.minCadence)")
                           .modifier(H4())
                       Text("Min")
                           .modifier(Label())
                    }
                }
                .foregroundColor(colorForRide(ride))
                .frame(maxWidth: self.sectionWidth / 12 * 2)
                .padding(2)
                .padding(.vertical, 5)
                .border(Color.gray, width: 0.2)
                .padding(2)
            }
        }
    }
}

struct DataSummaryTableView_Previews: PreviewProvider {
    static var previews: some View {
        let w = Workout.createDummyWorkout()
        return VStack {
            GeometryReader { geometry in
                VStack {
                    ForEach(DataType.allCases, id: \.self) { t in
                        VStack {
                            Text("\(t.rawValue)")
                            DataSummaryTableView(
                                dataType: t,
                                sectionWidth: geometry.size.width
                            )
                            .environmentObject(SelectedRides(rides: w.topRides()))
                            .environmentObject(w)
                        }
                    }
                }
            }
        }
    }
}
