//
//  FormattedSubCount.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-01-27.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct FormattedSubCount: View {
    @AppStorage("simplifyNumbers", store: .shared) var simplifyNumbers: Bool = false
    
    var count: String
    
    var formatted: String {
        if simplifyNumbers {
            return count.simplified()
        }
        
        return count.formattedWithSeparator()
    }
    
    var body: some View {
        Text(formatted)
            .fontWeight(.bold)
    }
}
