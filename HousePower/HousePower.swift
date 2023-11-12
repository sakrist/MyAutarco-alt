//
//  HousePower.swift
//  House Power
//
//  Created by Volodymyr Boichentsov on 29/10/2023.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    
    var modelData: ModelData
        
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        await modelData.pullAllToday()
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 10 {
            if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
                let entry = SimpleEntry(date: entryDate, configuration: configuration)
                entries.append(entry)
            }
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var configuration: ConfigurationAppIntent
}

struct HousePowerEntryView : View {
    var entry: Provider.Entry
    
    
    @Environment(ModelData.self) private var modelData

    var body: some View {
        
        VStack {
            HousePowerNowView(divider: false)
            
            Divider()
            
            HousePowerDateView()
        }
        .font(.system(size: 14))
    }
}


struct HousePower: Widget {
    let kind: String = "House Power"

    @State private var modelData = ModelData()
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, 
                               intent: ConfigurationAppIntent.self,
                               provider: Provider(modelData: modelData)) { entry in
            
            HousePowerEntryView(entry: entry)
                .environment(modelData)
                .modelContainer(for: DayRecord.self)
                .containerBackground(for: .widget, content: {
                    if (entry.configuration.graphType == 1) {
                        AreaGraphView( dataPoints: modelData.getDataPoints())
                    } else if (entry.configuration.graphType == 2) {
                        StackedHistogramView( dataPoints: modelData.getDataPoints(), showLabels: false)
                            .frame(height: 150)
                    }
                })
                
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var one: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.graphType = 1
        return intent
    }
    
    fileprivate static var two: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.graphType = 2
        return intent
    }
}

#Preview(as: .systemMedium) {
    HousePower()
} timeline: {
    SimpleEntry(date: .now, configuration: .one)
    SimpleEntry(date: .now, configuration: .two)
}
