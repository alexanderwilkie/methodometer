//
//  BluetoothDetail.swift
//  Methodometer
//
//  Created by Alex on 2020-02-16.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct LiveWorkoutDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject var session: Session
    @EnvironmentObject var workout: Workout

    var ride: Ride {
        return self.workout.myRide
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    /*Text(String(self.bike.name!))
                        .font(.headline)
                        .fontWeight(.heavy)*/
                    Text("\(self.ride.bikeID)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
            }
            .padding(.bottom, 25)
            
            HStack() {
                Spacer()
                VStack(alignment: .center) {
                    Text("\(self.workout.myRide.gearArray!.last!)")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("Gear")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
            }
            .padding(.bottom, 25)

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(self.ride.cadenceArray!.last!) RPM")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("Cadence")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(self.ride.powerArray!.last!) Watts")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("Power")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding(.bottom, 25)

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(secondsToString(Int(self.ride.elapsedDuration)))")
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
                    Text("\(self.ride.totalDistance, specifier: "%02.2f") Miles")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("Distance")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding(.bottom, 25)
            Spacer()
            Button(action: {
                self.session.stopSession()
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("STOP!")
            }
        }
        .padding()
        .navigationBarTitle(Text("Details"), displayMode: .inline)
        .onAppear {
            if (self.session.workout == nil) {
                self.session.configureFromWorkout(fromWorkout: self.workout, kbm: ContentView.kbm)
            }
        }
    }
}

struct LiveWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let goal: Session = Session()
        return LiveWorkoutDetailView()
            .environmentObject(goal)
    }
}
