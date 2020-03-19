//
//  WorkoutDetailView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-05.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var workout: Workout
    
    @State private var showRideSelectSheet = false
    @ObservedObject var selectedRides: SelectedRides
    
    @State private var offset: CGFloat = 0
    @State private var index = 0
    
    private let sectionHeight: CGFloat = 400
    
    init(selectedRides: SelectedRides = SelectedRides()) {
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
    
    func xOffset(_ ride: Ride) -> CGFloat{
        return CGFloat(ride.dateStarted!.timeIntervalSince(self.workout.dateStarted!))
    }
    
    var widthDivisor: CGFloat {
        return CGFloat(self.workout.duration/Double(self.workout.sampleRate))
    }
    
    func colorForRide(_ ride: Ride) -> Color {
        if (ride.myRide) {
            return Color("mPrimaryFG")
        }

        srand48(ride.bikeID.hashValue)
        return Color(hue: drand48(), saturation: 1, brightness: 0.75)
    }

    var body: some View {
        VStack {
            if (workout.managedObjectContext == nil) {
                EmptyView()
            } else {
            VStack {
                VStack(alignment: .leading) {
                    Text("\(workout.dateStarted!, formatter: WorkoutRowView.dateFormat)")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(workout.coachName!)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }.padding(.bottom)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(self.workout.myRide.totalDistance, specifier: "%02.2f") Miles")
                            .font(.headline)
                            .fontWeight(.heavy)
                        Text("Distance")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    VStack(alignment: .leading) {
                        Text("\(secondsToString(Int(self.workout.duration)))")
                            .font(.headline)
                            .fontWeight(.heavy)
                        Text("Duration")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(workout.myRide.bikeID)")
                            .font(.headline)
                            .fontWeight(.heavy)
                        Text("Bike")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }.padding(.bottom, 25)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(self.workout.myRide.maxCadence) RPM")
                            .font(.headline)
                            .fontWeight(.heavy)
                        Text("Max Cadence")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(self.workout.myRide.maxPower) Watts")
                            .font(.headline)
                            .fontWeight(.heavy)
                        Text("Max Power")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
            }.padding()
            Divider()
            VStack {
                Text("\(indexTitle)")
                    .font(.headline)
                    .fontWeight(.heavy)
                Button(action: {
                    self.showRideSelectSheet.toggle()
                }) {
                    HStack {
                        Text("Select Bikes")
                    }
                }
                .sheet(isPresented: $showRideSelectSheet) {
                    SelectRideModal(self.selectedRides)
                        .environmentObject(self.workout)
                }
            }
            GeometryReader { geometry in
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 20) {
                        
                        VStack {
                            ZStack {
                                ForEach(self.selectedRides.rides) { ride in
                                    LineGraphLine(
                                        array: ride.gearArray!.map({ Double($0) }),
                                        color: self.colorForRide(ride),
                                        xOffset: self.xOffset(ride),
                                        widthDivisor: self.widthDivisor,
                                        heightDivisor: CGFloat(24),
                                        frameWidth: geometry.size.width,
                                        frameHeight: self.sectionHeight
                                    )
                                }
                                LineGraphGrid(
                                    ySeries: 1...24,
                                    frameWidth: geometry.size.width,
                                    frameHeight: self.sectionHeight
                                )
                            }.frame(width: geometry.size.width, height: self.sectionHeight)
                        
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Bike")
                                    Divider()
                                    Text("Max")
                                    Divider()
                                    Text("Avg")
                                    Divider()
                                    Text("Min")
                                }.frame(width: geometry.size.width / 5)
                                HStack {
                                    ForEach(self.selectedRides.rides) { ride in
                                        VStack(alignment: .leading) {
                                            Text("\(ride.bikeID)")
                                                .font(.headline)
                                                .fontWeight(.heavy)
                                            Divider()
                                            Text("\(ride.maxGear)")
                                            Divider()
                                            Text("\(ride.avgGear)")
                                            Divider()
                                            Text("\(ride.minGear)")
                                        }
                                    }
                                }
                            }.padding()
                        }
                        
                        VStack {
                            ZStack {
                                ForEach(self.selectedRides.rides) { ride in
                                    LineGraphLine(
                                        array: ride.paceArray,
                                        color: self.colorForRide(ride),
                                        xOffset: self.xOffset(ride),
                                        widthDivisor: self.widthDivisor,
                                        heightDivisor: CGFloat(3),
                                        frameWidth: geometry.size.width,
                                        frameHeight: self.sectionHeight
                                    )
                                }
                                LineGraphGrid(
                                    ySeries: 2...4,
                                    frameWidth: geometry.size.width,
                                    frameHeight: self.sectionHeight
                                )
                            }.frame(width: geometry.size.width, height: self.sectionHeight)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Bike")
                                    Divider()
                                    Text("Max")
                                    Divider()
                                    Text("Avg")
                                    Divider()
                                    Text("Min")
                                }.frame(width: geometry.size.width / 5)
                                HStack {
                                    ForEach(self.selectedRides.rides) { ride in
                                        VStack(alignment: .leading) {
                                            Text("\(ride.bikeID)")
                                                .font(.headline)
                                                .fontWeight(.heavy)
                                            Divider()
                                            Text("\(ride.maxPace, specifier: "%02.2f")/m")
                                            Divider()
                                            Text("\(ride.avgPace, specifier: "%02.2f")/m")
                                            Divider()
                                            Text("\(ride.minPace, specifier: "%02.2f")/m")
                                        }
                                    }
                                }
                            }.padding()
                        }
                        
                        VStack {
                            ZStack {
                                ForEach(self.selectedRides.rides) { ride in
                                    LineGraphLine(
                                        array: ride.elapsedDistanceArray!,
                                        color: self.colorForRide(ride),
                                        xOffset: self.xOffset(ride),
                                        widthDivisor: self.widthDivisor,
                                        heightDivisor: CGFloat(self.workout.maxDistance),
                                        frameWidth: geometry.size.width,
                                        frameHeight: self.sectionHeight
                                    )
                                }
                                LineGraphGrid(
                                    ySeries: 0...Int(self.workout.maxDistance.rounded(.up)),
                                    frameWidth: geometry.size.width,
                                    frameHeight: self.sectionHeight
                                )
                            }.frame(width: geometry.size.width, height: self.sectionHeight)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Bike")
                                    Divider()
                                    Text("Total")
                                }.frame(width: geometry.size.width / 5)
                                HStack {
                                    ForEach(self.selectedRides.rides) { ride in
                                        VStack(alignment: .leading) {
                                            Text("\(ride.bikeID)")
                                                .font(.headline)
                                                .fontWeight(.heavy)
                                            Divider()
                                            Text("\(ride.totalDistance, specifier: "%02.2f")")
                                        }
                                    }
                                }
                            }.padding()
                        }
                        
                        VStack {
                            ZStack {
                                ForEach(self.selectedRides.rides) { ride in
                                    LineGraphLine(
                                        array: ride.powerArray!.map({ Double($0) }),
                                        color: self.colorForRide(ride),
                                        xOffset: self.xOffset(ride),
                                        widthDivisor: self.widthDivisor,
                                        heightDivisor: CGFloat(self.workout.maxPower),
                                        frameWidth: geometry.size.width,
                                        frameHeight: self.sectionHeight
                                    )
                                }
                                LineGraphGrid(
                                    ySeries: 0...self.workout.maxPower,
                                    yStep: 5,
                                    frameWidth: geometry.size.width,
                                    frameHeight: self.sectionHeight
                                )
                            }.frame(width: geometry.size.width, height: self.sectionHeight)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Bike")
                                    Divider()
                                    Text("Max")
                                    Divider()
                                    Text("Avg")
                                    Divider()
                                    Text("Min")
                                }.frame(width: geometry.size.width / 5)
                                HStack {
                                    ForEach(self.selectedRides.rides) { ride in
                                        VStack(alignment: .leading) {
                                            Text("\(ride.bikeID)")
                                                .font(.headline)
                                                .fontWeight(.heavy)
                                            Divider()
                                            Text("\(ride.maxPower)")
                                            Divider()
                                            Text("\(ride.avgPower)")
                                            Divider()
                                            Text("\(ride.minPower)")
                                        }
                                    }
                                }
                            }.padding()
                        }

                        VStack {
                            ZStack {
                                ForEach(self.selectedRides.rides) { ride in
                                    LineGraphLine(
                                        array: ride.cadenceArray!.map({ Double($0) }),
                                        color: self.colorForRide(ride),
                                        xOffset: self.xOffset(ride),
                                        widthDivisor: self.widthDivisor,
                                        heightDivisor: CGFloat(self.workout.maxCadence),
                                        frameWidth: geometry.size.width,
                                        frameHeight: self.sectionHeight
                                    )
                                }
                                LineGraphGrid(
                                    ySeries: 0...self.workout.maxCadence,
                                    yStep: 10,
                                    frameWidth: geometry.size.width,
                                    frameHeight: self.sectionHeight
                                )
                            }.frame(width: geometry.size.width, height: self.sectionHeight)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Bike")
                                    Divider()
                                    Text("Max")
                                    Divider()
                                    Text("Avg")
                                    Divider()
                                    Text("Min")
                                }.frame(width: geometry.size.width / 5)
                                HStack {
                                    ForEach(self.selectedRides.rides) { ride in
                                        VStack(alignment: .leading) {
                                            Text("\(ride.bikeID)")
                                                .font(.headline)
                                                .fontWeight(.heavy)
                                            Divider()
                                            Text("\(ride.maxCadence)")
                                            Divider()
                                            Text("\(ride.avgCadence)")
                                            Divider()
                                            Text("\(ride.minCadence)")
                                        }
                                    }
                                }
                            }.padding()
                        }
                    }
                }
            }}
        }
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let w = Workout.createDummyWorkout()
        return WorkoutDetailView(selectedRides: SelectedRides(rides: w.topRides()))
            .environmentObject(w)
    }
}
