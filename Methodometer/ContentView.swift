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
    @State private var showUserSettingsModal: Bool = false
    
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
    
    @FetchRequest(
        entity: Ride.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Ride.totalDistance, ascending: false)],
        predicate: NSPredicate(format: "myRide == true")
    ) var myRides: FetchedResults<Ride>
    
    func isDistancePB(_ workout: Workout) -> Bool {
        return workout.myRide.id == self.myRides.first!.id
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    if self.liveWorkouts.count > 0 {
                        Section(header: HStack {
                            Text("In Progress Workouts")
                            .modifier(H4())
                        }) {
                            ForEach(self.liveWorkouts) { (workout: Workout) in
                                NavigationLink(destination: LiveWorkoutDetailView(selectedRides: SelectedRides(rides: workout.topRides()))
                                    .environmentObject(self.session)
                                    .environmentObject(self.liveWorkouts.last!)
                                ) {
                                    WorkoutRowView(
                                        isDistancePB: self.isDistancePB(workout)
                                    )
                                    .environmentObject(self.liveWorkouts.last!)
                                }
                            }
                        }
                    }
                    if self.completedWorkouts.count > 0 {
                        Section(header:
                            Text("Completed Workouts")
                            .modifier(H4())
                        ) {
                            ForEach(completedWorkouts) { (workout: Workout) in
                                NavigationLink(destination:
                                    WorkoutDetailView(
                                        isDistancePB: self.isDistancePB(workout),
                                        selectedRides: SelectedRides(rides: workout.topRides())
                                    )
                                        .environmentObject(workout)
                                ) {
                                    WorkoutRowView(
                                        isDistancePB: self.isDistancePB(workout)
                                    )
                                    .environmentObject(workout)
                                }
                            }
                            .onDelete(perform: removeWorkout)
                            .id(self.refreshingID)
                        }
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
                trailing: HStack {
                    Button(action: {
                        self.showUserSettingsModal.toggle()
                    }) {
                        Image(systemName: "gear")
                    }.sheet(isPresented: $showUserSettingsModal) {
                        UserSettingView()
                            .environmentObject(UserPreferences.shared)
                    }
                    .frame(width: 25, height: 25)
                }
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
