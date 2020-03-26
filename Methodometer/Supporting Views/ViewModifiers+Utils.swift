//
//  ViewModifiers.swift
//  Methodometer
//
//  Created by Alex on 2020-03-18.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

let mediumDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

func colorForRide(_ ride: Ride) -> Color {
    if (ride.myRide) {
        return Color("mPrimaryFG")
    }

    srand48(ride.bikeID.hashValue)
    return Color(hue: drand48(), saturation: 1, brightness: 0.75)
}

struct Header: ViewModifier {
    var fontSize: CGFloat
    var monospaced: Bool=false

    func body(content: Content) -> some View {
        content
            .font(Font.system(
                size: fontSize,
                design: monospaced ? .monospaced : .default
            ).weight(.heavy).smallCaps())
    }
}

struct H1: ViewModifier {
    var caps: Bool = true
    let font = Font.system(size: 100.0)
                .weight(.heavy)
    
    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
    }
}

struct H2: ViewModifier {
    var caps: Bool = true
    let font = Font.system(size: 25.0)
                .weight(.heavy)
    
    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
    }
}

struct H3: ViewModifier {
    var caps: Bool = true
    let font = Font.headline
                .weight(.heavy)
    
    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
    }
}

struct H4: ViewModifier {
    var caps: Bool = true
    let font = Font.subheadline
                .weight(.heavy)

    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
    }
}

struct Emoji: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 22.0))
            .padding(.bottom, 3)
    }
}

struct Label: ViewModifier {
    var caps: Bool = true
    var color: Color = .gray
    let font = Font.system(size: 10)
                .weight(.light)
                .italic()

    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
            .foregroundColor(self.color)
    }
}

struct TextButton: ViewModifier {
    let buttonColor: Color
    var caps: Bool = true
    let font = Font.headline
                .weight(.heavy)

    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
            .foregroundColor(.white)
            .padding()
            .background(buttonColor)
            .cornerRadius(25)
    }
}
