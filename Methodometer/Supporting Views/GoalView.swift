//
//  GoalView.swift
//  Methodometer
//
//  Created by Alex on 2020-02-22.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct GoalView: View {
    
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var goal: Session
    static let kbm = KeiserBikeManager(simulated: true)

    @State private var coachName: String = ""
    @State private var selectedBike = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("New Workout")
                .font(.title)
                .padding(.bottom, 25)

            TextField("Coach Name", text: self.$coachName)
            
            Text("Bike")
            Picker(selection: $selectedBike, label: Text("")) {
                ForEach(GoalView.kbm.bikes, id: \.ordinalId) { bike in
                    Text("\(bike.ordinalId)").tag(bike.ordinalId)
                }
            }.id(GoalView.kbm.bikes) // this is to make sure it redraws as bikes come on line...
            
            Button(action: {
                self.goal.startSession(
                    coachName: self.coachName,
                    myBikeID: self.selectedBike,
                    kbm: GoalView.kbm,
                    live: true
                )
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("GO!")
            }
        }
        .padding()
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        let goal: Session = Session()
        goal.status = GoalStatus.running
        return GoalView()
            .environmentObject(goal)
            .environmentObject(KeiserBikeManager(simulated: true))
    }
}
