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
    
    @State var distance1: Int = 20
    @State var distance2: Int = 0
    @State var duration: Int = 60

    var newWorkoutView: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Group {
                    Text("Enter Coach Name:")
                        .modifier(H3())
                    TextField("Coach Name", text: self.$coachName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 25)
                }
                
                Group {
                    Text("Pick your bike:")
                        .modifier(H3())
                    HStack {
                        Spacer()
                        Picker(selection: self.$selectedBike, label: Text("")) {
                            ForEach(self.kbm.bikes, id: \.ordinalId) { bike in
                                Text("\(bike.ordinalId)").tag(bike.ordinalId)
                            }
                        }
                        .frame(maxWidth: (geometry.size.width / 2) + 10, maxHeight: 100)
                        .clipped()
                        .id(self.kbm.bikes) // this is to make sure it redraws as bikes come on line...
                        Spacer()
                    }
                }
                
                Group {
                    Text("Pick A Goal Distance:")
                        .modifier(H3())
                    Text("Miles")
                        .modifier(H4())
                    HStack(spacing: 0) {
                        Spacer()
                        Picker(selection: self.$distance1, label: Text("")) {
                            ForEach(10...30, id: \.self) { integer in
                                Text("\(integer)")
                            }
                        }
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: 100)
                        .clipped()
                        .padding(.trailing, 10)

                        Picker(selection: self.$distance2, label: Text("")) {
                            ForEach(0...9, id: \.self) { integer in
                                Text("\(integer)")
                            }
                        }
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: 100)
                        .clipped()
                        Spacer()
                    }
                }
            
                Text("Pick Workout Duration:")
                    .modifier(H3())
                Text("Minutes")
                    .modifier(H4())
                HStack {
                    Spacer()
                    Picker(selection: self.$duration, label: Text("")) {
                        ForEach(0...120, id: \.self) { minutes in
                            Text("\(minutes)")
                        }
                    }
                    .frame(maxWidth: (geometry.size.width / 2) + 10, maxHeight: 100)
                    .clipped()
                    .padding(.trailing)
                    Spacer()
                }
                
                Button(action: {
                    self.session.configure(
                        coachName: self.coachName,
                        myBikeID: self.selectedBike,
                        kbm: self.kbm
                    )
                    self.session.startSession()
                }) {
                    Text("GO!")
                }
                Spacer()
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
        return AnyView(LiveWorkoutDetailView()
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
