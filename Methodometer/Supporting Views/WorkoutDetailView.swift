//
//  WorkoutDetailView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-05.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct WorkoutDetailView: View {
    
    var isDistancePB: Bool = false
    @EnvironmentObject var workout: Workout
    
    @State private var showRideSelectSheet = false
    @ObservedObject var selectedRides: SelectedRides
    
    @State private var offset: CGFloat = 0
    @State private var index = 0
    
    private let sectionHeight: CGFloat = 400
    private let rowHeight: CGFloat = 38
    
    init(isDistancePB: Bool=false, selectedRides: SelectedRides = SelectedRides()) {
        self.isDistancePB = isDistancePB
        self.selectedRides = selectedRides
    }
    
    @State private var indexTitle: String = "Gear"
    let indexTitles: [String] = [
        "Gear",
        "Elapsed Distance",
        "Power",
        "Cadence",
        "Calories"
    ]

    var body: some View {
        VStack {
            if (workout.managedObjectContext == nil) {
                EmptyView()
            } else {
                VStack {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text("\(workout.coachName!)")
                                .modifier(H3())
                            Text("Coach")
                                .modifier(Label())
                            Spacer()
                        }
                        Spacer()
                        Text(rankToEmoji(self.workout.getRank(self.workout.myRide)))
                            .font(Font.system(size: 22.0))
                            .padding(.bottom, 3)
                            .padding(.trailing, -10)
                        Text(self.isDistancePB ? "🏆" : "")
                            .font(Font.system(size: 22.0))
                            .padding(.bottom, 3)
                        Divider()
                        VStack(alignment: .trailing) {
                            WorkoutRank(rank: self.workout.getRank(self.workout.myRide))
                            Text("Rank")
                                .modifier(Label())
                            Spacer()
                        }
                        VStack(alignment: .trailing) {
                            Text("\(workout.myRide.bikeID)")
                                .modifier(H3())
                            Text("Bike")
                                .modifier(Label())
                            Spacer()
                        }
                    }.frame(height: rowHeight)
                    Divider()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text("\(self.workout.myRide.totalDistance, specifier: "%02.2f") Miles")
                                .modifier(H3(caps: true))
                            Text("Distance")
                                .modifier(Label())
                        }
                        VStack(alignment: .leading) {
                            Text("\(secondsToString(Int(self.workout.duration)))")
                                .modifier(H3())
                            Text("Duration")
                                .modifier(Label())
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(self.workout.myRide.totalCalories)")
                                .modifier(H3())
                            Text("Calories")
                                .modifier(Label())
                        }
                    }.padding(.bottom, 5)
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(self.workout.myRide.avgCadence)/\(self.workout.myRide.maxCadence) RPM")
                                .modifier(H3())
                            Text("AVG/Max Cadence")
                                .modifier(Label())
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(self.workout.myRide.avgPower)/\(self.workout.myRide.maxPower) Watts")
                                .modifier(H3())
                            Text("AVG/Max Power")
                                .modifier(Label())
                        }
                    }.padding(.bottom, 5)
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(self.workout.myRide.avgGear)/\(self.workout.myRide.maxGear)")
                                .modifier(H3())
                            Text("AVG/Max Gear")
                                .modifier(Label())
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(self.workout.myRide.avgPace, specifier: "%02.2f")/\(self.workout.myRide.maxPace, specifier: "%02.2f")/m")
                                .modifier(H3())
                            Text("AVG/Max Pace")
                                .modifier(Label())
                        }
                    }.padding(.bottom, 5)
                    Divider()
                    GeometryReader { geometry in
                        ScrollView(showsIndicators: true) {
                            VStack {
                                VStack(alignment: .leading) {
                                    GearDataView(
                                        sectionWidth: geometry.size.width,
                                        sectionHeight: 500
                                    )
                                    .environmentObject(self.selectedRides)
                                    .environmentObject(self.workout)
                                }
                                
                                VStack(alignment: .leading) {
                                    PaceDataView(
                                        sectionWidth: geometry.size.width,
                                        sectionHeight: 500
                                    )
                                    .environmentObject(self.selectedRides)
                                    .environmentObject(self.workout)
                                }
                                
                                VStack(alignment: .leading) {
                                    DistanceDataView(
                                        sectionWidth: geometry.size.width,
                                        sectionHeight: 500
                                    )
                                    .environmentObject(self.selectedRides)
                                    .environmentObject(self.workout)
                                }
                                
                                VStack(alignment: .leading) {
                                    PowerDataView(
                                        sectionWidth: geometry.size.width,
                                        sectionHeight: 500
                                    )
                                    .environmentObject(self.selectedRides)
                                    .environmentObject(self.workout)
                                }
                                
                                VStack(alignment: .leading) {
                                    CadenceDataView(
                                        sectionWidth: geometry.size.width,
                                        sectionHeight: 500
                                    )
                                    .environmentObject(self.selectedRides)
                                    .environmentObject(self.workout)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("\(workout.dateStarted!, formatter: mediumDateFormat)"), displayMode: .inline)
        .navigationBarItems(
            trailing:
                HStack {
                    NavigationLink(destination: WorkoutTableView()
                        .environmentObject(self.workout)
                    ) {
                        Image(systemName: "line.horizontal.3")
                    }
                    .animation(.none)
                    .frame(width: 25, height: 25)

                    Button(action: {
                        self.showRideSelectSheet.toggle()
                    }) {
                        Image(systemName: "gear")
                    }.sheet(isPresented: $showRideSelectSheet) {
                        SelectRideModal(self.selectedRides)
                            .environmentObject(self.workout)
                    }
                    .frame(width: 25, height: 25)
                }
                
        )
        .padding()
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let w = Workout.createDummyWorkout(duration: 1)
        return WorkoutDetailView(
            isDistancePB: true,
            selectedRides: SelectedRides(rides: w.topRides())
        )
            .environmentObject(w)
    }
}
