//
//  ViewModifiers.swift
//  Methodometer
//
//  Created by Alex on 2020-03-18.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI
import CoreGraphics

struct ViewConstants {
    static let ROW_HEIGHT: CGFloat = 60
}

let mediumDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

func rankToEmoji(_ rank: Int) -> String {
    if rank == 1 {
        return "🥇"
    }
    if rank == 2 {
        return "🥈"
    }
    if rank == 3 {
        return "🥉"
    }
    return ""
}

func rankAndOrdinal(_ rank: Int) -> [String] {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    let ordinal = formatter.string(from: NSNumber(value: rank))!
    return [String(rank), String(ordinal.suffix(2))]
}

func colorForRide(_ ride: Ride) -> Color {
    if (ride.myRide) {
        return Color("mPrimaryFG")
    }

    return randomColor(ride.bikeID.hashValue)
}

func randomColor(_ hash: Int) -> Color {
    srand48(hash)
    return Color(hue: drand48(), saturation: 1, brightness: 0.75)
}

struct WorkoutRank: View {
    var rank: Int
    var body: some View {
        let rank = rankAndOrdinal(self.rank)
        return HStack(alignment: .lastTextBaseline) {
            Text(rank[0])
                .modifier(H3())
            Text(rank[1] != "" ? String(" " + rank[1]) : "")
                .modifier(Label())
                .padding(.leading, -10)
        }
    }
}

struct DistanceText : View {
    @ObservedObject var userPrefs: UserPreferences = UserPreferences.shared

    var d: Double
    var body: some View {
        Text("\(distanceForUnit(self.d, unit: userPrefs.distanceUnit), specifier: "%02.2f")")
    }
}

struct DistanceUnitText : View {
    @ObservedObject var userPrefs: UserPreferences = UserPreferences.shared

    var body: some View {
        Text("\(userPrefs.distanceUnit == .miles ? "Miles" : "KMs")")
    }
}

struct DurationText : View {
    @ObservedObject var userPrefs: UserPreferences = UserPreferences.shared
    
    var d: TimeInterval
    var allowedUnits: NSCalendar.Unit = [.minute]
    var toString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = self.allowedUnits
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: self.d)!
    }
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text("\(self.toString)")
                .modifier(H4())
            Text("Mins")
                .modifier(H5())
        }
    }
}


struct PaceText: View {
    @ObservedObject var userPrefs: UserPreferences = UserPreferences.shared

    var p: [Double]
    var toString: String {
        return self.p.map {
            secondsToString(Int(paceForUnit($0, unit: userPrefs.distanceUnit)))
        }
        .joined(separator: "/")
    }
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text("\(self.toString)")
                .modifier(H4())
            Text("\(userPrefs.distanceUnit == .miles ? "M/Mile" : "M/KM")")
                .modifier(H5())
        }
    }
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
    let font = Font.system(size: 20.0)
                .weight(.heavy)
    
    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
    }
}

struct H4: ViewModifier {
    var caps: Bool = true
    let font = Font.system(size: 15.0)
                .weight(.heavy)

    func body(content: Content) -> some View {
        content
            .font(caps ? font.smallCaps() : font)
    }
}

struct H5: ViewModifier {
    var caps: Bool = true
    let font = Font.system(size: 10.0)
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
