//
//  NewWorkoutView.swift
//  Methodometer
//
//  Created by Alex on 2020-02-22.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct NewWorkoutView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var session: Session
    @EnvironmentObject var kbm: KeiserBikeManager

    @State private var coachName: String = ""
    @State private var selectedBike = 0
    
    @State var distance: Double = 20
    @State var duration: Double = 60
    
    init()
    {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var isDisabled: Bool {
        return self.selectedBike == 0 || self.coachName.isEmpty
    }

    var newWorkoutView: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Form {
                    Section {
                        Text("Enter Coach Name:")
                            .modifier(H3())
                        TextField("Coach Name", text: self.$coachName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 5)
                            .keyboardType(.alphabet)
                            .autocapitalization(.words)
                        Picker(selection: self.$selectedBike, label: Text("Your Bike").modifier(H3())) {
                            ForEach(self.kbm.bikes, id: \.ordinalId) { bike in
                                Text("\(bike.ordinalId)").tag(bike.ordinalId)
                            }
                        }
                        .frame(maxWidth: (geometry.size.width / 2) + 10, maxHeight: 100)
                        .clipped()
                        .id(self.kbm.bikes) // this is to make sure it redraws as bikes come on line...
                        Text("Goal Distance: \(self.distance, specifier: "%02.1f") Miles")
                            .modifier(H3())
                        Slider(value: self.$distance, in: 10...30, step: 0.1)
                        Text("Workout Duration: \(self.duration, specifier: "%02.0f") Mins")
                            .modifier(H3())
                        Slider(value: self.$duration, in: 0...120, step: 1)
                    }
                    Section(footer: Text(self.isDisabled ? "*Enter coach name and select a bike before starting!" : "").foregroundColor(Color.red)) {
                        Button(action: {
                            self.session.configure(
                                coachName: self.coachName,
                                goalDuration: Int(self.duration) * 60,
                                goalDistance: self.distance,
                                myBikeID: self.selectedBike,
                                kbm: self.kbm
                            )
                            self.session.startSession()
                        }) {
                            HStack {
                                Spacer()
                                Text("START!")
                                    .modifier(TextButton(buttonColor: self.isDisabled ? .gray : .green))
                                Spacer()
                            }
                        }.disabled(self.isDisabled)
                    }
                }
            }
            .padding()
            .navigationBarTitle(Text("New Workout"), displayMode: .inline)
        }
    }
    
    var body: some View {
        if (self.session.status == .finished) {
            self.session.reset()
        }
    
        guard let _ = self.session.workout?.myRide else {
            return AnyView(self.newWorkoutView)
        }
        return AnyView(LiveWorkoutDetailView(
            selectedRides: SelectedRides(
                rides: self.session.workout!.topRides()
            )
        )
            .environmentObject(self.session)
            .environmentObject(self.session.workout!)
        )
    }
}

struct NewWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let session: Session = Session()
        return NewWorkoutView()
            .environmentObject(session)
            .environmentObject(KeiserBikeManager(simulated: true))
    }
}
