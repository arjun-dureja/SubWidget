//
//  Palette.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-02-17.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct Palette {
    let name: LocalizedStringResource
    let background: Color
    let accent: Color
    let number: Color

    static var presets: [Palette] = [
        .init(
            name: "Twilight",
            background: Color(hex: "#353342"),
            accent: Color(hex: "#fbeeea"),
            number: Color(hex: "#0099d4")
        ),
        .init(
            name: "Nautical",
            background: Color(hex: "#243369"),
            accent: Color(hex: "#e6e2e3"),
            number: Color(hex: "#c7a256")
        ),
        .init(
            name: "Emerald",
            background: Color(hex: "#002c34"),
            accent: Color(hex: "#fcfdfd"),
            number: Color(hex: "#16b248")
        ),
        .init(
            name: "Harvest",
            background: Color(hex: "#e5cc3f"),
            accent: Color(hex: "#6c1a0e"),
            number: Color(hex: "#e54d14")
        ),
        .init(
            name: "Patriot",
            background: Color(hex: "#fdffff"),
            accent: Color(hex: "#172c6a"),
            number: Color(hex: "#b51722")
        ),
        .init(
            name: "Amethyst",
            background: Color(hex: "#e6a5fb"),
            accent: Color(hex: "#4300a9"),
            number: Color(hex: "#5d09b2")
        ),
        .init(
            name: "Deepsea",
            background: Color(hex: "#003240"),
            accent: Color(hex: "#f4f6f4"),
            number: Color(hex: "#71c6d1")
        ),
        .init(
            name: "Orchid",
            background: Color(hex: "#f6ecff"),
            accent: Color(hex: "#371a48"),
            number: Color(hex: "#d606e8")
        ),
        .init(
            name: "Minted",
            background: Color(hex: "#59cfa1"),
            accent: Color(hex: "#000002"),
            number: Color(hex: "#255353")
        ),
        .init(
            name: "Coral",
            background: Color(hex: "#fbdeba"),
            accent: Color(hex: "#1d441d"),
            number: Color(hex: "#5a9ecc")
        ),
        .init(
            name: "Ruby",
            background: Color(hex: "#af2c3b"),
            accent: Color(hex: "#ffb844"),
            number: Color(hex: "#fffefe")
        ),
        .init(
            name: "Onyx",
            background: Color(hex: "#141414"),
            accent: Color(hex: "#cfd3cf"),
            number: Color(hex: "#a0bcc3")
        )
    ]
}
