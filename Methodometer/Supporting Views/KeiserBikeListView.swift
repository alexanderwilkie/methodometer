//
//  BluetoothList.swift
//  Methodometer
//
//  Created by Alex on 2020-02-15.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct KeiserBikeListView: View {
    @EnvironmentObject var kbm: KeiserBikeManager
    
    var body: some View {
        List(self.kbm.foundBikes, id: \.self) { bike in
            NavigationLink(
                destination: KeiserBikeDetailView()
                    .environmentObject(bike)
            ) {
                VStack(alignment: .leading) {
                    Text(bike.name!)
                        .font(.subheadline)
                        .fontWeight(.heavy)
                    HStack {
                        Text("Bike ID:")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .italic()
                        Text(String(bike.ordinalId))
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
            }
            .padding()
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(Text("Available Bikes"), displayMode: .inline)
    }
}

struct KeiserBikeListView_Previews: PreviewProvider {
    static var previews: some View {
        let kbm = KeiserBikeManager()
        for _ in 1...30 {
            kbm.foundBikes.append(KeiserBike.fakeRandomBike(duration: 0))
        }
        return KeiserBikeListView().environmentObject(kbm)
    }
}
