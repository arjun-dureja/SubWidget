//
//  WidgetBundle.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2024-02-03.
//  Copyright © 2024 Arjun Dureja. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct SubWidgets: WidgetBundle {
   var body: some Widget {
       SubscriberCount()
       ViewCount()
   }
}
