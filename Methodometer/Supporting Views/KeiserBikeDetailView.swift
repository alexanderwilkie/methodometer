//
//  BluetoothDetail.swift
//  Methodometer
//
//  Created by Alex on 2020-02-16.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct KeiserBikeDetailView: View {
    @EnvironmentObject var bike: KeiserBike
    @EnvironmentObject var goal: Goal

    @State private var showModal: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(String(self.bike.name!))
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(bike.ordinalId)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
                Button(action: {
                    // has *a* bike
                    if self.goal.hasBike() {
                        // but is it the right bike?
                        if (self.goal.isValidForBike(self.bike)) {
                            // probbly something useful to show
                        }
                    } else {
                        self.showModal = true
                    }
                }) {
                    // has *a* bike
                    if self.goal.hasBike() {
                        // but is it the right bike?
                        if (self.goal.isValidForBike(self.bike)) {
                            Image(systemName: "bolt.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "bolt.circle")
                            .foregroundColor(.gray)
                        }
                    } else {
                        Image(systemName: "bolt.circle")
                        .foregroundColor(.green)
                    }
                    
                }
                .animation(.none)
                .frame(width: 25, height: 25)
                .buttonStyle(CircleButtonStyle())
                .sheet(isPresented: self.$showModal) {
                    GoalView()
                        .environmentObject(self.goal)
                        //.environmentObject(self.bike)
                }
            }
            .padding(.bottom, 25)
            
            HStack() {
                Spacer()
                VStack(alignment: .center) {
                    Text("\(self.bike.gear!)")
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
                    Text("\(self.bike.cadence!) RPM")
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
                    Text("\(self.bike.power!) Watts")
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
                    Text("\(secondsToString(Int(self.bike.duration!)))")
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
                    Text("\(self.bike.tripDistance!, specifier: "%02.2f") Miles")
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
            
            if (self.goal.isValidForBike(bike)) {
                HStack() {
                    VStack(alignment: .center) {
                        Text("Goal Details")
                            .font(.callout)
                            .fontWeight(.heavy)
                    }
                    Spacer()
                }
                .padding(.bottom, 25)
                
                VStack {
                    HStack() {
                        Spacer()
                        VStack(alignment: .center) {
                            Text("\(self.goal.elapsedDistance, specifier: "%02.2f") Miles")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(self.goal.onTarget() ? .green : .red)
                            Text("Elapsed Distance")
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
                            HStack {
                                Text("\(secondsToString(self.goal.elapsedDuration))")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                            }
                            Text("Elapsed Duration")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                                .italic()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(self.goal.targetDistance, specifier: "%02.2f") Miles")
                                .font(.headline)
                                .fontWeight(.heavy)
                            Text("Goal Target Distance")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                                .italic()
                        }
                    }
                    .padding(.bottom, 25)
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(secondsToString(Int(self.goal.duration)))")
                                  .font(.headline)
                                  .fontWeight(.heavy)
                            Text("Goal Duration")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                                .italic()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(self.goal.distance, specifier: "%02.2f") Miles")
                                .font(.headline)
                                .fontWeight(.heavy)
                            Text("Goal Distance")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                                .italic()
                        }
                    }
                    .padding(.bottom, 25)
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text("Details"), displayMode: .inline)
    }
}

struct KeiserBikeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let goal: Goal = Goal()
        goal.status = GoalStatus.running
        return KeiserBikeDetailView()
            .environmentObject(KeiserBike.fakeRandomBike())
            .environmentObject(goal)
    }
}
