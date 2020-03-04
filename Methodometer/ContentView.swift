//
//  ContentView.swift
//  Methodometer
//
//  Created by Alex on 2020-02-11.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var kbm = KeiserBikeManager(simulated: true)
    
    @State var mode = KeiserBikeManagerType.none
    @State var goal = Goal()
    
    @State private var coachName: String = ""
    @State private var showModal: Bool = false

    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.dateStarted, ascending: false)]
    ) var completedWorkouts: FetchedResults<Workout>

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                List {
                    ForEach(completedWorkouts){ workout in
                        WorkoutRowView(workout: workout)
                    }
                }
            }
            .navigationBarTitle(Text("Methodometer"), displayMode: .inline)
            .navigationBarItems(leading:
                NavigationLink(destination: GoalView()
                    .environment(\.managedObjectContext, self.context)
                    .environmentObject(self.goal)
                    .environmentObject(self.kbm)
                ) {
                    Image(systemName: "plus.circle")
                }
                .animation(.none)
                .frame(width: 25, height: 25)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for _ in 0...Int.random(in: 0...10) {
            Workout.randomWorkout(context: context)
        }

        return ContentView().environment(\.managedObjectContext, context)
    }
}
