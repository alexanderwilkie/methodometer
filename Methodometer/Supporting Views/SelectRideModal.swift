//
//  SelectRideModal.swift
//  Methodometer
//
//  Created by Alex on 2020-03-09.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct SelectRideModal: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var workout: Workout
    
    @State private var selections = [Ride]()
    @ObservedObject var selectedRides: SelectedRides
    
    @State var hackyHash: Int = 0
    
    init(_ selectedRides: SelectedRides) {
        self.selectedRides = selectedRides
        print(selectedRides.rides)
    }
    
    var body: some View {
        Group {
            VStack {
                Text("Select Rides")
                Button(action: {
                    self.selectedRides.rides = self.selections
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                }
            }
            List {
                ForEach(self.workout.allRides) { ride in
                    RideMultiSelectRow(
                        isSelected: self.selections.contains(ride),
                        action: {
                            if self.selections.contains(ride) {
                                self.selections.removeAll(where: { $0 == ride })
                            }
                            else {
                                self.selections.append(ride)
                            }
                        }
                    )
                        .environmentObject(ride)
                        .id(self.hackyHash)
                }
            }.onAppear(perform: {
                self.selections = self.selectedRides.rides
                self.hackyHash = Int.random(in: 0...999)
            })
        }
    }
}
