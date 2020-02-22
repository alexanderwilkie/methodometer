//
//  ContentView.swift
//  Methodometer
//
//  Created by Alex on 2020-02-11.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var distance: Float = 20
    @State var duration: Float = 3600
    @State var timeRemaining: Int = 0
    @State var odometer: Float = 0
    
    @State var timer: Timer?
    
    @EnvironmentObject var kbm: KeiserBikeManager

    var methodometerToggle: Bool {
        true
    }
    
    func secondsToMinutes(_ seconds: Int) -> Int {
        return Int(seconds / 60)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Duration: \(self.secondsToMinutes(Int(duration))):00")
                            .font(.headline)
                        Text("Minutes")
                            .font(.footnote)
                            .fontWeight(.light)
                        Slider(value: $duration, in: 0.0...7200.0, step: 60)
                    }
                    VStack(alignment: .leading) {
                        Text("Distance: \(distance, specifier: "%.2f")")
                            .font(.headline)
                        Text("Miles")
                            .font(.footnote)
                            .fontWeight(.light)
                        Slider(value: $distance, in: 0.0...40.0, step: 0.1)
                    }
                }
                .padding(.bottom, 25)
                HStack {
                    Button(action: {
                        if (self.timer != nil) {
                            self.timer?.invalidate()
                            self.timer = nil
                        }
                        else {
                            if (self.timeRemaining == 0) {
                                self.timeRemaining = Int(self.duration)
                            }
                            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                                self.timeRemaining -= 1
                                self.odometer += self.distance / self.duration
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: self.timer != nil ? "pause.circle" : "bolt.circle")
                                .font(.title)
                            Text(self.timer != nil ? "PAUSE!" : "GO!")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(self.timer != nil ? Color.red : Color.green)
                        .cornerRadius(40)
                    }
                    
                    NavigationLink(destination: KeiserBikeListView().environmentObject(self.kbm)) {
                        HStack {
                            Image(systemName: "wifi")
                                .font(.title)
                            Text("CONNECT!")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(40)
                    }
                }
                
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("Remaining Time")
                            .font(.headline)
                        Spacer()
                    }
                    Text("Minutes")
                        .font(.footnote)
                        .fontWeight(.light)
                }
                    
                HStack(alignment: .center) {
                    Group {
                        Text("\(self.secondsToMinutes(self.timeRemaining), specifier: "%02d")")
                            .padding(.horizontal, -5)
                        Text(":")
                        Text("\(self.timeRemaining - (self.secondsToMinutes(self.timeRemaining) * 60), specifier: "%02d")")
                            .padding(.horizontal, -5)
                    }
                    .font(.largeTitle)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Goal Distance")
                            .font(.headline)
                        Spacer()
                    }
                    Text("Miles")
                        .font(.footnote)
                        .fontWeight(.light)
                }
                
                HStack(alignment: .center) {
                    Text("\(self.odometer, specifier: "%0.2f")")
                        .font(.largeTitle)
                }
            }
            .padding()
            .navigationBarTitle(Text("Home"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(
            KeiserBikeManager.fakeSession(bikes: 32, duration: 60)
        )
    }
}
