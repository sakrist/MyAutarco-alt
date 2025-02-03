//
//  HousePower.swift
//  House Power
//
//  Created by Volodymyr Boichentsov on 29/10/2023.
//

import Combine
import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    
    var modelData: ModelData
        
    func placeholder(in context: Context) -> SimpleEntry {
        let record = DayRecord(name: "today", date: Date())
        let config = ConfigurationAppIntent()
        ConfigurationAppIntent.isUpdating = true
        return SimpleEntry(date: Date(), configuration: config, record:record)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        ConfigurationAppIntent.isUpdating = true
        await modelData.pullAllToday()
        
        let record = DayRecord(name: "today", date: Date())
        record.now = modelData.today.now
        record.dataPoints = modelData.getDataPoints()
        record.summary = modelData.today.summary
        let entry = SimpleEntry(date: .now, configuration: configuration, record: record)
        ConfigurationAppIntent.isUpdating = false
        return entry
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        ConfigurationAppIntent.isUpdating = true
        await modelData.pullAllToday()
        let record = DayRecord(name: "today", date: Date())
        record.now = modelData.today.now
        record.dataPoints = modelData.getDataPoints()
        record.summary = modelData.today.summary

        let oneHourLater = Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now
        let entry = SimpleEntry(date: oneHourLater, configuration: configuration, record: record)
        ConfigurationAppIntent.isUpdating = false
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var configuration: ConfigurationAppIntent
    var record:DayRecord
}

struct HousePowerEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        
        VStack {
            HousePowerNowView(divider: false, record: entry.record)
            
            Divider()
            
            HousePowerDateView(record: entry.record)
        }
        .font(.system(size: 14))
    }
}


struct HousePower: Widget {
    let kind: String = "House Power"

    let modelData = ModelData.shared
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, 
                               intent: ConfigurationAppIntent.self,
                               provider: Provider(modelData: modelData)) { entry in
            HousePowerEntryView(entry: entry)
                .environment(modelData)
                .modelContainer(for: DayRecord.self)
                .containerBackground(for: .widget, content: {
                    if (entry.configuration.graphType == 1) {
                        AreaGraphView( dataPoints: entry.record.dataPoints)
                    } else if (entry.configuration.graphType == 2) {
                        StackedHistogramView( dataPoints: entry.record.dataPoints, showLabels: false)
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
    let record = DayRecord(name: "Now", date: .now)
    SimpleEntry(date: .now, configuration: .one, record: record)
    SimpleEntry(date: .now, configuration: .two, record: record)
}
