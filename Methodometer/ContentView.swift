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
        
    @State var mode = KeiserBikeManagerType.none
    @State var goal = Session()
    
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
                    ForEach(completedWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView()
                                .environmentObject(workout)) {
                            WorkoutRowView()
                                .environmentObject(workout)
                        }
                    }.onDelete(perform: removeWorkout)
                }
            }
            .navigationBarTitle(Text("Methodometer"), displayMode: .inline)
            .navigationBarItems(leading:
                NavigationLink(destination: GoalView()
                    .environment(\.managedObjectContext, self.context)
                    .environmentObject(self.goal)
                ) {
                    Image(systemName: "plus.circle")
                }
                .animation(.none)
                .frame(width: 25, height: 25)
            )
        }
    }
    
    func removeWorkout(at offsets: IndexSet) {
        for index in offsets {
            context.delete(completedWorkouts[index])
        }
        do {
            try context.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        for _ in 0...Int.random(in: 0...10) {
            Session.fakeSession()
        }
        return ContentView().environment(\.managedObjectContext, context)
    }
}
