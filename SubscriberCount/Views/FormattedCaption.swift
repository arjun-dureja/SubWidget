//
//  FormattedCaption.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-02-04.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import SwiftUI

struct FormattedCaption: View {
    let widgetType: WidgetType

    var caption: String {
        switch widgetType {
        case .subscribers:
            "Total subscribers"
        case .views:
            "Total views"
        }
    }

    var body: some View {
        Text(caption)
    }
}
