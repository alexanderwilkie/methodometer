//
//  MultiSelectRow.swift
//  Methodometer
//
//  Created by Alex on 2020-03-09.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct RideMultiSelectRow: View {
    @EnvironmentObject var ride: Ride

    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                RideRowView().environmentObject(ride)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

struct RideMultiSelectRow_Previews: PreviewProvider {
    static var previews: some View {
        let workout: Workout = Session.fakeSession().workout!            
        return RideMultiSelectRow(isSelected: true, action: {})
            .environmentObject(workout.myRide)
    }
}
