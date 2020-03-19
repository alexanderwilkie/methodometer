//
//  ContentView.swift
//  Methodometer
//
//  Created by Alex on 2020-02-11.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct ContentView: View {
        
    static let kbm = KeiserBikeManager(simulated: true)
    @State var session = Session()
    @State private var showModal: Bool = false
    
    @State private var refreshingID = UUID()

    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.dateStarted, ascending: false)],
        predicate: NSPredicate(format: "statusString == %@", WorkoutStatus.live.rawValue)
    ) var liveWorkouts: FetchedResults<Workout>
    
    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.dateStarted, ascending: false)],
        predicate: NSPredicate(format: "statusString == %@", WorkoutStatus.completed.rawValue)
    ) var completedWorkouts: FetchedResults<Workout>

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if (self.liveWorkouts.count > 0) {
                    Text("In Progress Workouts")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    NavigationLink(destination: LiveWorkoutDetailView()
                        .environmentObject(self.session)
                        .environmentObject(self.liveWorkouts.last!)
                    ) {
                        WorkoutRowView()
                            .environmentObject(self.liveWorkouts.last!)
                    }
                    .padding(.horizontal)
                    .frame(height: 60)
                }
                if (self.completedWorkouts.count > 0) {
                    VStack(alignment: .leading) {
                        Text("Completed Workouts")
                            .font(.headline)
                            .fontWeight(.heavy)
                            .padding(.top)
                            .padding(.horizontal)
                        List {
                            ForEach(completedWorkouts) { (workout: Workout) in
                                NavigationLink(destination:
                                    WorkoutDetailView()
                                        .environmentObject(workout)
                                ) {
                                    WorkoutRowView()
                                        .environmentObject(workout)
                                }
                            }
                            .onDelete(perform: removeWorkout)
                            .id(self.refreshingID)
                        }
                    }
                }
                if (self.liveWorkouts.count <= 0 && self.completedWorkouts.count <= 0) {
                    List {
                        Text("No workouts yet!")
                    }
                }
            }
            .navigationBarTitle(Text("Methodometer"), displayMode: .inline)
            .navigationBarItems(
                leading:
                    NavigationLink(destination: NewWorkoutView()
                        .environmentObject(self.session)
                        .environmentObject(ContentView.kbm)
                    ) {
                        Image(systemName: "plus.circle")
                    }
                    .animation(.none)
                    .frame(width: 25, height: 25),
                trailing: EditButton()
            )
        }
    }
    
    func removeWorkout(at offsets: IndexSet) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        for index in offsets {
            let workout = completedWorkouts[index]
            workout.status = .junked
            context.delete(workout)
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        self.refreshingID = UUID()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let _ = Workout.createDummyWorkout(duration: 1490, status: WorkoutStatus.live)
        for _ in 0...Int.random(in: 0...3) {
            let _ = Workout.createDummyWorkout()
        }
        return ContentView().environment(\.managedObjectContext, context)
    }
}
