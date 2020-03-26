//
//  WorkoutRank.swift
//  Methodometer
//
//  Created by Alex on 2020-03-20.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

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

struct WorkoutRank_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRank(rank: 21)
    }
}
