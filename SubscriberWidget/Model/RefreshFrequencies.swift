//
//  RefreshFrequencies.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-06-26.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import Foundation

enum RefreshFrequencies: Double, CaseIterable, Codable {
    case THIRTY_MIN = 30
    case ONE_HR = 60
    case SIX_HR = 180
    case TWELVE_HR = 720
    
    func toString() -> String {
        switch self {
        case .THIRTY_MIN:
            "30 Minutes"
        case .ONE_HR:
            "1 Hour"
        case .SIX_HR:
            "6 Hours"
        case .TWELVE_HR:
            "12 Hours"
        }
    }
}
