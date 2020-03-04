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
    @Environment(\.managedObjectContext) var context

    @EnvironmentObject var goal: Goal
    @EnvironmentObject var kbm: KeiserBikeManager

    @State private var coachName: String = ""
    @State private var dateStarted = Date()
    @State private var selectedBike = 0

    /*
    func addWorkout() {
        let newWorkout = Workout(context: context)
        newWorkout.id = UUID()
        newWorkout.dateStarted = Date()
        newWorkout.coachName = coachName

        do {
            try context.save()
        } catch {
            print(error)
        }
    }*/
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("New Workout")
                .font(.title)
                .padding(.bottom, 25)

            TextField("Coach Name", text: self.$coachName)
            
            Text("\(self.kbm.bikes.count)")
            DatePicker("", selection: self.$dateStarted, in: Date()...)
                .labelsHidden()
                .frame(height: 125)
                .clipped()
            
            Text("Bike")
            Picker(selection: $selectedBike, label: Text("")) {
                ForEach(self.kbm.bikes, id: \.ordinalId) { bike in
                    Text("\(bike.ordinalId)").tag(bike.ordinalId)
                }
            }.id(self.kbm.bikes)
            
            Button(action: {
                self.goal.startWorkout(
                    context: self.context,
                    workout: Workout.createWorkout(
                        context: self.context,
                        dateStarted: self.dateStarted,
                        coachName: self.coachName
                    ),
                    myBikeID: self.selectedBike,
                    kbm: self.kbm
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
        let goal: Goal = Goal()
        goal.status = GoalStatus.running
        return GoalView()
            .environmentObject(goal)
            .environmentObject(KeiserBikeManager(simulated: true))
    }
}
