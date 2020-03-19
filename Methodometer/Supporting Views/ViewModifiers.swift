//
//  ViewModifiers.swift
//  Methodometer
//
//  Created by Alex on 2020-03-18.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct H3: ViewModifier {
    let font = Font.headline
                .weight(.heavy)
                .smallCaps()
    
    func body(content: Content) -> some View {
        content
            .font(font)
    }
}

struct H4: ViewModifier {
    let font = Font.subheadline
                .weight(.light)
                .smallCaps()
                .italic()

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(.gray)
    }
}
