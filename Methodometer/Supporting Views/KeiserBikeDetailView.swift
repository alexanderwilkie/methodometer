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
                    Text(String(self.bike.ordinalId))
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text(String(self.bike.ordinalId))
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle(Text("Details"), displayMode: .inline)
    }
}

struct KeiserBikeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        KeiserBikeDetailView().environmentObject(
            KeiserBike(
                ordinalId: 19, buildMajor: 3, buildMinor: 6, cadence: 134,
                heartRate: 155, power: 500, caloricBurn: 800, duration: 344,
                tripDistance: 4.5, gear: 18
            )
        )
    }
}
