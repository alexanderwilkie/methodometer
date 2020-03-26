//
//  DistanceDataView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-21.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct DistanceDataView: View {
    @EnvironmentObject var selectedRides: SelectedRides
    @EnvironmentObject var workout: Workout

    var sectionWidth: CGFloat = 400
    var sectionHeight: CGFloat = 400
    
    func getGraphData() -> [GraphData] {
        var g = [GraphData]()
        for ride in self.selectedRides.rides {
            g.append(GraphData(
                array: ride.elapsedDistanceArray!,
                color: colorForRide(ride),
                xOffset: xOffset(self.workout, ride)
            ))
        }
        return g
    }

    var body: some View {
        VStack {
            HStack {
                Text("Distance")
                    .modifier(H2())
                Spacer()
            }
            ZStack {
                LineGraph(
                    data: self.getGraphData(),
                    xSeries: 0...Int(self.workout.duration),
                    ySeries: 0...Int(self.workout.maxDistance.rounded(.up)),
                    frameWidth: self.sectionWidth,
                    frameHeight: self.sectionHeight
                )
            }
            DataSummaryTableView(
                dataType: .distance,
                sectionWidth: self.sectionWidth
            )
            .environmentObject(self.selectedRides)
            .environmentObject(self.workout)
        }
    }
}

struct DistanceDataView_Previews: PreviewProvider {
    static var previews: some View {
        let w = Workout.createDummyWorkout()
        return Group {
            GeometryReader { geometry in
                DistanceDataView(
                    sectionWidth: geometry.size.width,
                    sectionHeight: 500
                )
                .environmentObject(SelectedRides(rides: w.topRides()))
                .environmentObject(w)
            }
        }
    }
}
