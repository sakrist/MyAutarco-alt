//
//  AppIntent.swift
//  House Power
//
//  Created by Volodymyr Boichentsov on 29/10/2023.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "House Energy"
    static var description = IntentDescription("Widget to show house energy production and consumption.")
    
    @Parameter(title: "Graph Type", default: 1)
    var graphType: Int
}
