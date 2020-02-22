//
//  GoalView.swift
//  Methodometer
//
//  Created by Alex on 2020-02-22.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct GoalView: View {
    
    @EnvironmentObject var goal: Goal
    @Environment(\.presentationMode) var presentationMode
    
    func secondsToMinutes(_ seconds: Int) -> Int {
        return Int(seconds / 60)
    }
    
    // self.odometer += self.distance / self.duration
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Duration: \(self.secondsToMinutes(Int(goal.duration))):00")
                        .font(.headline)
                    Text("Minutes")
                        .font(.footnote)
                        .fontWeight(.light)
                    Slider(value: $goal.duration, in: 0.0...7200.0, step: 60)
                }
                VStack(alignment: .leading) {
                    Text("Distance: \(goal.distance, specifier: "%.2f")")
                        .font(.headline)
                    Text("Miles")
                        .font(.footnote)
                        .fontWeight(.light)
                    Slider(value: $goal.distance, in: 0.0...40.0, step: 0.1)
                }
            }
            .padding(.bottom, 25)
            
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("GO!")
            }
            
            Spacer()
        }
        .padding()
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        return GoalView()
    }
}
