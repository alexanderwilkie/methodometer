//
//  RideRowView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-10.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct RideRowView: View {
    @EnvironmentObject var ride: Ride
    
    var body: some View {
        HStack {
            Text("\(ride.bikeID, specifier: "%02d")")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(ride.myRide ? Color.green : Color("mPrimaryFG"))
            Divider()
            VStack(alignment: .leading) {
                Text("\(ride.totalDistance, specifier: "%02.2f") Miles")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                    .italic()
                Text("\(ride.avgGear) - Average Gear")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                    .italic()
            }
            Spacer()
        }.padding()
    }
}

struct RideRowView_Previews: PreviewProvider {
    static var previews: some View {
        return RideRowView()
            .environmentObject(Ride.createDummyRide(duration: 3600, myRide: true, bikeID: 6))
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
