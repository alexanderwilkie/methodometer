//
//  DistanceMarkerView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-29.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.linear(duration: 1)
            .speed(4)
            .delay(0.01 * Double(index))
    }
}

struct DistanceMarkerView: View {
    
    @EnvironmentObject var ride: Ride
    var offset: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ForEach(Range(0...100)) { i in
                    Path { path in
                        let x = convertToRange(
                            CGFloat(i),
                            from: 0...100,
                            to: 0...geometry.size.width
                        )
                        path.move(to: CGPoint(
                            x: x,
                            y: 0
                        ))
                        path.addLine(to: CGPoint(
                            x: x,
                            y: geometry.size.height - 10
                        ))
                    }
                    .stroke(Color.gray, lineWidth: 0.25)
                    .scaleEffect(
                        x: 1,
                        y: self.ride.passingMilestone() ? 0 : 1,
                        anchor: .bottom
                    )
                    .animation(.ripple(index: i))
                }
                Rectangle()
                    .offset(x: 0, y: 5)
                    .foregroundColor(Color("mPrimaryBG"))
                    .frame(height: geometry.size.height-20)

                ForEach(Range(0...10)) { i in
                    Path { path in
                        let x = convertToRange(
                            CGFloat(i),
                            from: 0...10,
                            to: 0...geometry.size.width
                        )
                        path.move(to: CGPoint(
                            x: x,
                            y: 0
                        ))
                        path.addLine(to: CGPoint(
                            x: x,
                            y: geometry.size.height - 5
                        ))
                    }
                    .stroke(Color("mPrimaryFG"), lineWidth: 0.5)
                    .scaleEffect(
                        x: 1,
                        y: self.ride.passingMilestone() ? 0 : 1,
                        anchor: .top
                    )
                    .animation(.ripple(index: i))
                }
                Rectangle()
                    .offset(x: 0, y: 10)
                    .foregroundColor(Color("mPrimaryBG"))
                    .opacity(0.85)
                    .frame(height: geometry.size.height - 30)

                ForEach(Range(0...10)) { i in
                    ZStack {
                        Text("\(Double(i) / 10 + Double(self.offset), specifier: "%02.01f")")
                        .modifier(Header(
                            fontSize: 10,
                            monospaced: true
                        ))
                        .position(
                            x: convertToRange(
                                CGFloat(i),
                                from: 0...10,
                                to: 0...geometry.size.width
                            ),
                            y: geometry.size.height - 5
                        )
                        .scaleEffect(
                            x: 1,
                            y: self.ride.passingMilestone() ? 0 : 1,
                            anchor: .bottom
                        )
                        .animation(.ripple(index: i))
                    }
                }
                
                Text("\(self.ride.elapsedDistanceArray!.last!, specifier: "%02.02f")")
                    .position(
                        x: convertToRange(
                            CGFloat(modf(self.ride.elapsedDistanceArray!.last!).1),
                            from: 0...1,
                            to: 0...geometry.size.width
                        ) - 20,
                        y: geometry.size.height / 2 - 5.5
                    )
                    .modifier(Header(
                        fontSize: 10,
                        monospaced: true
                    ))
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(colorForRide(self.ride))
                    .position(
                        x: convertToRange(
                            CGFloat(modf(self.ride.elapsedDistanceArray!.last!).1),
                            from: 0...1,
                            to: 0...geometry.size.width
                        ),
                        y: geometry.size.height / 2 - 5
                    )
            }.clipped()
        }
    }
}

struct DistanceMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        let session: Session = Session.fakeSession()
        return DistanceMarkerView()
            .environmentObject(session.workout!.myRide)
            .frame(height: 80)
    }
}
