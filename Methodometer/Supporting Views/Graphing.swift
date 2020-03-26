//
//  Graphing.swift
//  Methodometer
//
//  Created by Alex on 2020-03-07.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

func xOffset(_ workout: Workout, _ ride: Ride) -> CGFloat{
    return CGFloat(ride.dateStarted!.timeIntervalSince(workout.dateStarted!))
}

func widthDivisor(_ workout: Workout) -> CGFloat {
    return CGFloat(workout.duration/Double(workout.sampleRate))
}

class GraphData: Identifiable {
    let id: UUID = UUID()
    
    var array: [Double]
    var color: Color
    var xOffset: CGFloat
    
    init(array: [Double], color: Color, xOffset: CGFloat) {
        self.array = array
        self.color = color
        self.xOffset = xOffset
    }
}

struct LineGraph: View {
    
    let data: [GraphData]
    let xSeries: ClosedRange<Int>
    let ySeries: ClosedRange<Int>
    
    var yStep: Int = 1
    var gridXStep: Int = 4

    let frameWidth: CGFloat
    let frameHeight: CGFloat

    // To give the axis space
    private let textOffset: CGFloat = 20
    
    // To give the xAxis space
    private let xOffset: CGFloat = 30
    
    // how much the gridlines overhang
    private let overhang: CGFloat = 5

    var gridWidth: CGFloat {
        return (self.frameWidth - self.xOffset * 2) / CGFloat(self.gridXStep)
    }
    
    var gridHeight: CGFloat {
        return self.frameHeight / CGFloat(self.ySeries.last! + 1)
    }
    
    var xStep: CGFloat {
        return (self.frameWidth - self.xOffset * 2) / CGFloat(self.xSeries.count - 1)
    }
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            ForEach(self.ySeries, id: \.self) { line in
                Group {
                    if (line % self.yStep == 0) {
                        Text("\(line)")
                        .offset(
                            x: -self.frameWidth + self.textOffset,
                            // + 5 to bring in line with line
                            y: -(CGFloat(line) * self.gridHeight) - self.textOffset + 5
                        )
                        .modifier(Label())
                        
                        Path { path in
                            // some reason it's inverse
                            let y = self.frameHeight - CGFloat(line) * self.gridHeight - self.textOffset
                            path.move(to: CGPoint(
                                x: self.xOffset - self.overhang,
                                y: y
                            ))
                            path.addLine(to: CGPoint(
                                x: self.frameWidth - self.xOffset + self.overhang,
                                y: y
                            ))
                        }.stroke(Color.gray, lineWidth: 0.25)
                    } else {
                        EmptyView()
                    }
                }
            }
            ForEach(0...gridXStep, id: \.self) { line in
                Path { path in
                    let x = (CGFloat(line) * self.gridWidth) + self.xOffset
                    path.move(to: CGPoint(
                        x: x,
                        y: self.frameHeight - self.textOffset + self.overhang
                    ))
                    path.addLine(to: CGPoint(
                        x: x,
                        y: self.gridHeight - self.textOffset - self.overhang
                    ))
                }.stroke(Color.gray, lineWidth: CGFloat(0.25))
            }
            
            ForEach(self.data) { d in
                Path { p in
                    p.move(to: CGPoint(
                        x: (CGFloat(d.xOffset) * self.xStep) + self.xOffset,
                        y: self.frameHeight - CGFloat(d.array[0]) * self.gridHeight - self.textOffset
                    ))

                    d.array.indices.forEach { i in
                        let x = (d.xOffset + CGFloat(i) * self.xStep) + self.xOffset
                        let y = self.frameHeight - (CGFloat(d.array[i]) * self.gridHeight + self.textOffset)
                        
                        p.addLine(to:CGPoint(x: x, y: y))
                    }
                }
                .stroke(style: StrokeStyle(lineWidth: CGFloat(1)))
                .foregroundColor(d.color)
            }
        }
        .frame(width: self.frameWidth, height: self.frameHeight)
    }
}

struct Graphing_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 10) {
                    ZStack(alignment: .leading) {
                        LineGraph(
                            data: [GraphData(
                                array: Array(1...10).map({ Double($0) }),
                                color: Color.red,
                                xOffset: 0
                            )],
                            xSeries: 0...9,
                            ySeries: 0...10,
                            frameWidth: geometry.size.width,
                            frameHeight: geometry.size.height
                        )
                    }
                }
            }
        }
    }
}
