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
    @EnvironmentObject var bts: BLEManagerDelegate
    
    var body: some View {
        List {
            ForEach(self.bts.filterNamedPeripherals) { p in
                NavigationLink(
                    destination: KeiserBikeDetailView()
                        .environmentObject(self.bts)
                        .environmentObject(p)
                ) {
                    VStack(alignment: .leading) {
                        Text(p.advertisedName!)
                            .font(.subheadline)
                            .fontWeight(.heavy)
                        Text(p.state.stringRepresentation)
                            .font(.subheadline)
                            .fontWeight(.light)
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
        KeiserBikeListView().environmentObject(BLEManagerDelegate())
    }
}
