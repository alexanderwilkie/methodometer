//
//  ContentView.swift
//  Methodometer
//
//  Created by Alex on 2020-02-11.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var mode = KeiserBikeManagerType.none

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                if (self.mode == KeiserBikeManagerType.live) {
                    KeiserBikeListView()
                        .environmentObject(KeiserBikeManager())
                        .animation(.spring())
                        .transition(.slide)
                } else if (self.mode == KeiserBikeManagerType.demo) {
                    KeiserBikeListView()
                        .environmentObject(KeiserBikeManager(simulated: true))
                        .animation(.spring())
                        .transition(.slide)
                } else {
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.mode = KeiserBikeManagerType.live
                            }
                        }) {
                            HStack {
                                Image(systemName: "bolt.circle")
                                    .font(.title)
                                Text("LIVE!")
                                    .fontWeight(.semibold)
                                    .font(.subheadline)
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(40)
                        }.animation(.none)
                        
                        Button(action: {
                            withAnimation {
                                self.mode = KeiserBikeManagerType.demo
                            }
                        }) {
                            HStack {
                                Image(systemName: "bolt.circle")
                                    .font(.title)
                                Text("DEMO!")
                                    .fontWeight(.semibold)
                                    .font(.subheadline)
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .cornerRadius(40)
                        }.animation(.none)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
