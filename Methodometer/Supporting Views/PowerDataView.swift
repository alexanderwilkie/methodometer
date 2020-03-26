//
//  PowerDataView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-21.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct PowerDataView: View {
    @EnvironmentObject var selectedRides: SelectedRides
    @EnvironmentObject var workout: Workout

    var sectionWidth: CGFloat = 400
    var sectionHeight: CGFloat = 400
    
    func getGraphData() -> [GraphData] {
        var g = [GraphData]()
        for ride in self.selectedRides.rides {
            g.append(GraphData(
                array: ride.powerArray!.map({ Double($0) }),
                color: colorForRide(ride),
                xOffset: xOffset(self.workout, ride)
            ))
        }
        return g
    }

    var body: some View {
        VStack {
            HStack {
                Text("Power")
                    .modifier(H2())
                Spacer()
            }
            ZStack {
                LineGraph(
                    data: self.getGraphData(),
                    xSeries: 0...Int(self.workout.duration),
                    ySeries: 0...self.workout.maxPower,
                    yStep: 10,
                    frameWidth: self.sectionWidth,
                    frameHeight: self.sectionHeight
                )
            }
            DataSummaryTableView(
                dataType: .power,
                sectionWidth: self.sectionWidth
            )
            .environmentObject(self.selectedRides)
            .environmentObject(self.workout)
        }
    }
}

struct PowerDataView_Previews: PreviewProvider {
    static var previews: some View {
        let w = Workout.createDummyWorkout()
        return Group {
            GeometryReader { geometry in
                PowerDataView(
                    sectionWidth: geometry.size.width,
                    sectionHeight: 500
                )
                .environmentObject(SelectedRides(rides: w.topRides()))
                .environmentObject(w)
            }
        }
    }
}
