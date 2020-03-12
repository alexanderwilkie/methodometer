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
    @EnvironmentObject var goal: Session

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
            
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text("Details"), displayMode: .inline)
    }
}

struct KeiserBikeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let goal: Session = Session()
        goal.status = GoalStatus.running
        return KeiserBikeDetailView()
            .environmentObject(KeiserBike.fakeRandomBike())
            .environmentObject(goal)
    }
}
