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
    @ObservedObject var selectedRides = SelectedRides()
    
    @State private var offset: CGFloat = 0
    @State private var index = 0
    
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
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 10) {
                        ZStack(alignment: .top) {
                            ForEach(self.selectedRides.rides) { ride in
                                LineGraphLine(
                                    array: ride.gearArray!.map({ Double($0) }),
                                    color: self.colorForRide(ride),
                                    xOffset: self.xOffset(ride),
                                    widthDivisor: self.widthDivisor,
                                    heightDivisor: CGFloat(24),
                                    frameWidth: geometry.size.width,
                                    frameHeight: geometry.size.height
                                )
                            }
                            LineGraphGrid(
                                ySeries: 1...24,
                                frameWidth: geometry.size.width,
                                frameHeight: geometry.size.height
                            )
                        }.frame(width: geometry.size.width)
                        
                        ZStack {
                            ForEach(self.selectedRides.rides) { ride in
                                LineGraphLine(
                                    array: ride.elapsedDistance!,
                                    color: self.colorForRide(ride),
                                    xOffset: self.xOffset(ride),
                                    widthDivisor: self.widthDivisor,
                                    heightDivisor: CGFloat(self.workout.maxDistance),
                                    frameWidth: geometry.size.width,
                                    frameHeight: geometry.size.height
                                )
                            }
                            LineGraphGrid(
                                ySeries: 0...Int(self.workout.maxDistance.rounded(.up)),
                                frameWidth: geometry.size.width,
                                frameHeight: geometry.size.height
                            )
                        }.frame(width: geometry.size.width)
                        
                        ZStack {
                            ForEach(self.selectedRides.rides) { ride in
                                LineGraphLine(
                                    array: ride.powerArray!.map({ Double($0) }),
                                    color: self.colorForRide(ride),
                                    xOffset: self.xOffset(ride),
                                    widthDivisor: self.widthDivisor,
                                    heightDivisor: CGFloat(self.workout.maxPower),
                                    frameWidth: geometry.size.width,
                                    frameHeight: geometry.size.height
                                )
                            }
                            LineGraphGrid(
                                ySeries: 0...self.workout.maxPower,
                                yStep: 5,
                                frameWidth: geometry.size.width,
                                frameHeight: geometry.size.height
                            )
                        }.frame(width: geometry.size.width)
                        
                        ZStack {
                            ForEach(self.selectedRides.rides) { ride in
                                LineGraphLine(
                                    array: ride.cadenceArray!.map({ Double($0) }),
                                    color: self.colorForRide(ride),
                                    xOffset: self.xOffset(ride),
                                    widthDivisor: self.widthDivisor,
                                    heightDivisor: CGFloat(self.workout.maxCadence),
                                    frameWidth: geometry.size.width,
                                    frameHeight: geometry.size.height
                                )
                            }
                            LineGraphGrid(
                                ySeries: 0...self.workout.maxCadence,
                                yStep: 10,
                                frameWidth: geometry.size.width,
                                frameHeight: geometry.size.height
                            )
                        }.frame(width: geometry.size.width)
                        
                        ZStack {
                            ForEach(self.selectedRides.rides) { ride in
                                LineGraphLine(
                                    array: ride.caloricBurnArray!.map({ Double($0) }),
                                    color: self.colorForRide(ride),
                                    xOffset: self.xOffset(ride),
                                    widthDivisor: self.widthDivisor,
                                    heightDivisor: CGFloat(self.workout.maxCaloricBurn),
                                    frameWidth: geometry.size.width,
                                    frameHeight: geometry.size.height
                                )
                            }
                            LineGraphGrid(
                                ySeries: 0...self.workout.maxCaloricBurn,
                                frameWidth: geometry.size.width,
                                frameHeight: geometry.size.height
                            )
                        }.frame(width: geometry.size.width)
                    }
                }
                .content.offset(x: self.offset)
                .frame(width: geometry.size.width, alignment: .leading)
                .gesture(
                    DragGesture()
                    .onChanged({ value in
                        self.offset = value.translation.width - geometry.size.width * CGFloat(self.index)
                    })
                    .onEnded({ value in
                        if -value.predictedEndTranslation.width > geometry.size.width / 2, self.index < 5 - 1 {
                            self.index += 1
                            self.indexTitle = self.indexTitles[self.index]
                        }
                        if value.predictedEndTranslation.width > geometry.size.width / 2, self.index > 0 {
                            self.index -= 1
                            self.indexTitle = self.indexTitles[self.index]
                        }
                        withAnimation { self.offset = -(geometry.size.width + 10) * CGFloat(self.index)
                        }
                    })
                )
            }
        }
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return WorkoutDetailView()
            .environmentObject(Workout.createDummyWorkout())
    }
}
