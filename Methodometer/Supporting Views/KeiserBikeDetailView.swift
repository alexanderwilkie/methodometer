//
//  BluetoothDetail.swift
//  Methodometer
//
//  Created by Alex on 2020-02-16.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct KeiserBikeDetailView: View {
    @EnvironmentObject var bike: KeiserBike

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(String(self.bike.name!))
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(bike.ordinalId)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
            }
            Spacer()
            HStack() {
                Spacer()
                VStack(alignment: .center) {
                    Text("\(self.bike.gear!)")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("Gear")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
            }
            Spacer()
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Cadence")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(self.bike.cadence!)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Power")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(self.bike.power!)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            Spacer()
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(self.bike.duration!)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Distance")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(self.bike.tripDistance!)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            Spacer()
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Heartrate")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(self.bike.heartRate!)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Caloric Burn")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(self.bike.caloricBurn!)")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text("Details"), displayMode: .inline)
    }
}

struct KeiserBikeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        KeiserBikeDetailView().environmentObject(
            KeiserBike.fakeRandomBike(duration: 0)
        )
    }
}
