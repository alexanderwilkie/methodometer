//
//  Graphing.swift
//  Methodometer
//
//  Created by Alex on 2020-03-07.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct LineGraphGrid: View {
    let ySeries: ClosedRange<Int>
    var yStep: Int = 1

    let frameWidth: CGFloat
    let frameHeight: CGFloat
    
    var dHeight: CGFloat {
        return self.frameHeight / CGFloat(self.ySeries.last! + 1)
    }
    
    var body: some View {
        ForEach(ySeries, id: \.self) { line in
            ZStack {
                if (line % self.yStep == 0) {
                    Path { path in
                        let y = self.frameHeight - CGFloat(line) * self.dHeight
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: self.frameWidth, y: y))
                    }.stroke(Color.gray, lineWidth: 0.25)
                    
                    Text("\(line)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .background(Color("mPrimaryBG"))
                    .opacity(1)
                    .offset(
                        x: -(self.frameWidth / 2) + 20,
                        y: (self.frameHeight / 2) - (CGFloat(line) + 1) * self.dHeight
                    )
                } else {
                    EmptyView()
                }
            }
            .frame(width: self.frameWidth, height: self.frameHeight)
            
        }
    }
}

struct LineGraphLine: View {
    
    let array: [Double]
    
    let color: Color
    
    let xOffset: CGFloat
    
    let widthDivisor: CGFloat
    let heightDivisor: CGFloat
    
    let frameWidth: CGFloat
    let frameHeight: CGFloat
    
    var body: some View {
        
        let dWidth = self.frameWidth / self.widthDivisor
        let dHeight = self.frameHeight / (self.heightDivisor + 1)
        
        return Group {
            Path { p in
                p.move(to: CGPoint(
                    x: CGFloat(self.xOffset) * dWidth,
                    y: self.frameHeight - CGFloat(self.array[0]) * dHeight
                ))
                
                self.array.indices.forEach { i in
                    if (i % 1 == 0) {
                        let x = CGFloat(Int(self.xOffset) + i) * dWidth
                        let y = self.frameHeight - (CGFloat(self.array[i]) * dHeight)
                        
                        p.addLine(to:CGPoint(x: x, y: y))
                        
                        /*
                        p.addEllipse(
                            in: CGRect(
                                x: x - 1,
                                y: y - 1,
                                width: 2,
                                height: 2
                            )
                        )
                        
                        // reset after drawing ellipse
                        p.move(to: CGPoint(x: x, y: y))
                        */
                    }
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 1))
            .foregroundColor(self.color)
        }
    }
}

struct Graphing_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 10) {
                    ZStack(alignment: .leading) {
                        LineGraphLine(
                            array: Array(1...24).map({ Double($0) }),
                            color: Color.red,
                            xOffset: 0,
                            widthDivisor: 23,
                            heightDivisor: 24,
                            frameWidth: geometry.size.width,
                            frameHeight: geometry.size.height
                        )
                        LineGraphGrid(
                            ySeries: 1...24,
                            frameWidth: geometry.size.width,
                            frameHeight: geometry.size.height
                        )
                    }
                }
            }
        }
    }
}
