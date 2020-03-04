//
//  BluetoothList.swift
//  Methodometer
//
//  Created by Alex on 2020-02-15.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct KeiserBikeListView: View {
    @EnvironmentObject var kbm: KeiserBikeManager
    @EnvironmentObject var goal: Goal

    var body: some View {
        NavigationView {
            List(self.kbm.foundBikes.values.sorted(by: {$0.ordinalId < $1.ordinalId})) { bike in
                NavigationLink(
                    destination: KeiserBikeDetailView()
                        .environmentObject(bike)
                        .environmentObject(self.goal)
                ) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bike.name!)
                                .font(.subheadline)
                                .fontWeight(.heavy)
                            HStack {
                                Text("Bike ID:")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                    .foregroundColor(.gray)
                                    .italic()
                                Text(String(bike.ordinalId))
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.gray)
                                    .italic()
                            }
                        }
                        Spacer()
                        if (self.goal.isValidForBike(bike)) {
                            Image(systemName: "bolt.circle")
                                .font(.body)
                                .foregroundColor(.green)
                                .frame(width: 15, height: 15)
                                .padding(.trailing, 25)
                        }
                    }
                }
                .padding()
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle(Text("Available Bikes"), displayMode: .inline)
        }
    }
}

struct KeiserBikeListView_Previews: PreviewProvider {
    static var previews: some View {
        let goal: Goal = Goal()
        goal.status = GoalStatus.running
        
        return KeiserBikeListView()
            .environmentObject(KeiserBikeManager(simulated: true))
            .environmentObject(goal)
    }
}
