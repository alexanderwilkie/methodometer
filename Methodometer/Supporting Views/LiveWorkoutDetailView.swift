//
//  BluetoothDetail.swift
//  Methodometer
//
//  Created by Alex on 2020-02-16.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct DataView {
    var label: String
    var unit: String
    var value: String
}

struct LiveWorkoutDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showRideSelectSheet = false
    @ObservedObject var selectedRides: SelectedRides

    @EnvironmentObject var session: Session
    @EnvironmentObject var workout: Workout
    
    @State var index: Int = 0
    @State var endIndex: Int = 0

    func toRange(_ number: CGFloat, maxWidth: CGFloat) -> Int {
        return Int(((number - 0) / (maxWidth - 0) * 5).rounded(.down))
    }

    var ride: Ride {
        return self.workout.myRide
    }
    
    func dataForIndex(_ index: Int) -> DataView {
        if index == 0 {
            return DataView(
                label: "Gear",
                unit: "",
                value: String(format: "%02d", self.ride.gearArray!.last ?? 0)
            )
        }
        else if index == 1 {
            return DataView(
                label: "Cadence",
                unit: "RPM",
                value: String(format: "%03d", self.ride.cadenceArray!.last ?? 0)
            )
        }
        else if index == 2 {
            return DataView(
                label: "Power",
                unit: "Watts",
                value: String(format: "%03d", self.ride.powerArray!.last ?? 0)
            )
        }
        if index == 3 {
            return DataView( //secondsToString(Int(
                label: "Duration",
                unit: "MM:SS",
                value: String(secondsToString(Int(self.ride.elapsedDuration)))
            )
        }
        
        return DataView(
            label: "Distance",
            unit: "Miles",
            value: String(format: "%02.02f", self.ride.totalDistance)
        )
    }
    
    func dataView(
        _ indexOffset: Int,
        _ halign: HorizontalAlignment,
        _ isLarge: Bool=false
    ) -> AnyView {
        let d = self.dataForIndex((self.index + indexOffset) % 5)
        return AnyView(
            VStack(alignment: halign, spacing: -3) {
                Text(d.value)
                .modifier(Header(
                    fontSize: isLarge ? 60 : 30,
                    monospaced: true
                ))
                Text(d.unit.isEmpty ? d.label : d.unit)
                .modifier(Header(fontSize: isLarge ? 20 : 15))
                .fixedSize()
                .padding(.top, isLarge ? -10 : 0)
                Text(d.unit.isEmpty ? " " : d.label)
                    .modifier(Label())
            }
        )
    }
    
    var scrolldots: some View {
        HStack(alignment: .top) {
            Spacer()
            ForEach(0...4, id: \.self) { i in
                Circle()
                .overlay(
                    Circle()
                    .stroke(Color("mPrimaryFG"), lineWidth: 1)
                ).foregroundColor(i == self.index ? Color("mPrimaryFG") : Color("mPrimaryBG"))
                .frame(width: 3, height: 3)
            }
            Spacer()
        }
    }
    
    var sparklines: some View {
        VStack {
            DistanceMarkerView()
                .environmentObject(self.ride)
                .frame(height: 40)
            ForEach(self.selectedRides.otherRides) { ride in
                DistanceMarkerView()
                    .environmentObject(ride)
                    .frame(height: 40)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: -2) {
                Group { // Header body
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text("\(self.workout.coachName!)")
                                .modifier(H3())
                            Text("Coach")
                                .modifier(Label())
                        }
                        Spacer()
                        Text(rankToEmoji(self.workout.getRank(self.ride)))
                            .font(Font.system(size: 24.0))
                            .padding(.bottom, -4)
                            .padding(.trailing, -5)
                        Divider().frame(height:35)
                        VStack(alignment: .trailing) {
                            WorkoutRank(rank: self.workout.getRank(self.ride))
                            Text("Rank")
                                .modifier(Label())
                        }
                        VStack(alignment: .trailing) {
                            Text("\(self.ride.bikeID)")
                                .modifier(H3())
                            Text("Bike")
                                .modifier(Label())
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                Divider()
                
                ZStack { // Data body
                    VStack {
                        HStack(alignment: .top) {
                            self.dataView(1, .leading)
                            Spacer()
                            self.dataView(4, .trailing)
                        }
                        .padding(.bottom, 50)
                        HStack(alignment: .top) {
                            self.dataView(2, .leading)
                            Spacer()
                            self.dataView(3, .trailing)
                        }
                        
                        self.scrolldots
                            .padding(.bottom, 15)
                    }
                    HStack(alignment: .top) {
                        Spacer()
                        self.dataView(0, .center, true)
                        Spacer()
                    }
                    .offset(y: -10)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            let r = self.toRange(
                                value.translation.width,
                                maxWidth: geometry.size.width
                            )
                            self.index = mod(self.endIndex + r, 5)

                        })
                        .onEnded({ value in
                            let r = self.toRange(
                                value.translation.width,
                                maxWidth: geometry.size.width
                            )
                            self.endIndex = mod(self.endIndex + r, 5)
                        })
                )
                
                VStack { // Sparkline body
                    Divider()
                    self.sparklines
                    .padding()
                    Spacer()
                }
                Group { // Footer
                    Divider()
                    Button(action: {
                        self.session.stopSession()
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("STOP!")
                                .modifier(TextButton(buttonColor: .red))
                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .navigationBarTitle(Text("\(self.workout.dateStarted!, formatter: mediumDateFormat)"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack {
                        Button(action: {
                            self.showRideSelectSheet.toggle()
                        }) {
                            Image(systemName: "gear")
                        }.sheet(isPresented: self.$showRideSelectSheet) {
                            SelectRideModal(self.selectedRides)
                                .environmentObject(self.workout)
                        }
                        .frame(width: 25, height: 25)
                    }
            )
            .onAppear {
                if (self.session.workout == nil) {
                    self.session.configureFromWorkout(fromWorkout: self.workout, kbm: ContentView.kbm)
                }
            }
        }
    }
}

// The remainder operator (%) is also known as a modulo operator in other
// languages. However, its behavior in Swift for negative numbers means that,
// strictly speaking, it’s a remainder rather than a modulo operation.
func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

struct LiveWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let session: Session = Session.fakeSession()
        return LiveWorkoutDetailView(
            selectedRides: SelectedRides(rides: session.workout!.topRides())
        )
            .environmentObject(session)
            .environmentObject(session.workout!)
    }
}
