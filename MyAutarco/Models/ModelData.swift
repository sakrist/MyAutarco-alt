//
//  ModelData.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import SwiftUI
import Foundation
import SwiftData

struct NowPowerStatus : Codable {
    var pv:Int = 0 // total PV producing in watt
    var pvSelf:Int = 0 // self consumption of pv energy in watt
    var grid:Int = 0 // consumed from grid in watt
    var battery:Int = 0 // consumed from battery in watt
    var battery_charge:Int = 0 // current battery charge in %
    var total:Int = 0 // total consumed atm in watt
}

struct SummaryPowerStatus : Codable {
    var pv:Int = 0 // today PV produced in kWh
    var grid:Int = 0 // consumed from grid, if negative then it is given to grid
    var consumed:Int = 0 // today PV + Grid + Battery consumed in kWh
}


@Observable final class ModelData {
    
    public var modelContext: ModelContext?
    
    var client = AutarcoAPIClient()
    
    var today = DayRecord(name: "Today", date: .now)

    var inverters = [String]()
    
    var isLoading = false
    
    var selectedDate = Date()
    
    // Function to check if a date is today
    func isDateToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let otherDate = calendar.startOfDay(for: date)
        return today == otherDate
    }
    
    // MARK: - Now
    
    func pullAllToday() async {
        self.isLoading = true
        
        selectedDate = Date()
        
        if (client.public_key.isEmpty) {
            await client.getPublicKey()
        }
        
        if (self.inverters.isEmpty) {
            await power()
        }
        
        var recordsFetch = FetchDescriptor<DayRecord>(predicate: #Predicate { $0.name == "today" })
        recordsFetch.fetchLimit = 1
        recordsFetch.includePendingChanges = true
        let records = try? modelContext?.fetch(recordsFetch)
        
        if let found = records?.first, selectedDate.timeIntervalSince(found.date) < 290 {
            self.today.now = found.now
            self.today.summary = found.summary
            self.dataPoints = found.dataPoints.map { $0 }
            self.isLoading = false
            return
        }
        
        await power()
        await energy()
        
        await pull(date: selectedDate)
        
        let record = DayRecord(name: "today", date: selectedDate)
        record.now = today.now
        record.dataPoints = dataPoints.map { $0 }
        record.summary = today.summary
        modelContext?.insert(record)
        try? modelContext?.save()
        
        self.isLoading = false
    }

    func pull(date:Date) async {
        self.isLoading = true
        defer {
            self.isLoading = false
        }
        
        if (self.inverters.isEmpty) {
            await power()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: date)
        
        let isToday = isDateToday(date)
        
        if !isToday {
            var recordsFetch = FetchDescriptor<DayRecord>(predicate: #Predicate { $0.name == dateString })
            recordsFetch.fetchLimit = 1
            recordsFetch.includePendingChanges = true
            let records = try? modelContext?.fetch(recordsFetch)
            
            if let found = records?.first {
                self.today.summary = found.summary
                self.dataPoints = found.dataPoints.map { $0 }
                if (self.dataPoints.count > 0 ) {
                    self.isLoading = false
                    return
                }
            }
        }
        
        
        
        await consumption(date: date)
        await pullTimeline(date: date)
        
        if !isToday, let modelContext = modelContext {
            let record = DayRecord(name: dateString, date: date)
            record.dataPoints = dataPoints.map { $0 }
            record.summary = today.summary
            modelContext.insert(record)
            try? modelContext.save()
        }
    }
    
    func power() async {
        await client.doRequest(path: "kpis/power") { json in
            if let json = json as? [String: Any] {
                self.today.now.pv = Int(json["pv_now"] as? Int ?? 0)
                self.today.now.grid = Int(json["consumed_now"] as? Int ?? 0)
                self.today.now.battery = Int(json["battery_now"] as? Int ?? 0)
                
                self.today.now.total = max(0, self.today.now.pv + self.today.now.grid - self.today.now.battery)
                self.today.now.pvSelf = max(0, min(self.today.now.pv + self.today.now.grid, self.today.now.pv));
                
                if self.inverters.count == 0, let invs = json["inverters"] as? [String : Any ] {
                    for item in invs {
                        self.inverters.append(item.key)
                    }
                }
            } else {
                self.client.errorMessage = "Failed to parse kpis/power"
            }
        }
    }
    
    func energy() async {
        await client.doRequest(path: "kpis/energy") { json in
            if let json = json as? [String: Any] {
//                self.totalStatus.pv = Int(json["pv_today"] as? Int ?? 0)
                self.today.now.battery_charge = Int(json["battery_soc"] as? Int ?? 0)
            } else {
                self.client.errorMessage = "Failed to parse kpis/energy"
            }
        }
    }
    
    // MARK: - consumption today
    
    
    /// Stats right now!
    /// - Parameters:
    ///   - date: for the day need data
    func consumption(date:Date) async {
        
        var mondayDateString = ""
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let currentWeekday = calendar.component(.weekday, from: date)
        mondayDateString = dateFormatter.string(from: date)
        if currentWeekday != 2 {
            // Calculate the number of days to subtract to get to the previous Monday
            let daysToSubtract = (currentWeekday - 2 + 7) % 7
            if let previousMonday = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) {
                mondayDateString = dateFormatter.string(from: previousMonday)
            }
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        var consumed = 0
        
        if let inverter = self.inverters.first {
            // energy from inverter
            // https://my.autarco.com/api/site/[api_key]/inverter/[inverter]/energy?r=week&d=20231030
            await client.doRequest(path: "inverter/\(inverter)/energy?r=week&d=\(mondayDateString)") { json in
                if let json = json as? [String: Any] {
                    if let energy = json["energy"] as? [String: Int?] {
                        let pv = (energy[dateString] ?? 0) ?? 0
                        self.today.summary.pv = pv
                        consumed += pv
                    }
                }
            }
        }
        
        // energy from grid
        // URL: https://my.autarco.com/api/site/[api_key]/consumption/energy?r=week&d=20231030
        await client.doRequest(path: "consumption/energy?r=week&d=\(mondayDateString)") { json in
            if let json = json as? [String: Any] {
                if let energy = json["energy"] as? [String: Int?] {
                    let grid = (energy[dateString] ?? 0) ?? 0
                    self.today.summary.grid = grid
                    consumed += grid
                }
            }
        }
        
        // energy from battery
        // for some reason here we subtract
        // URL: https://my.autarco.com/api/site/[api_key]/batterypack/energy?r=week&d=20231030
        await client.doRequest(path: "batterypack/energy?r=week&d=\(mondayDateString)") { json in
            if let json = json as? [String: Any] {
                if let energy = json["energy"] as? [String: Int?] {
                    consumed -= (energy[dateString] ?? 0) ?? 0
                }
            }
        }
        self.today.summary.consumed = consumed
    }
    
    // MARK: - timeline
    
    
    static func convertTimeline(_ inverter: [String : Int?], _ grid: [String : Int?], _ battery: [String : Int?]) -> [DataPoint] {
        
        var dataPoints: [DataPoint] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate = Calendar.current
        let minutesInDay: Double = 24 * 60
        
        // Iterate over the keys (dates) in one of the dictionaries (assuming they all have the same keys)
        for date in inverter.keys {
            if let inverterValue = inverter[date],
                let gridValue = grid[date],
                let batteryValue = battery[date] {
                    
                let inverterValue = max(inverterValue ?? 0, 0)
                let batteryValue = batteryValue ?? 0
                let gridValue = gridValue ?? 0
                
                let consumption = max(0, inverterValue + gridValue - batteryValue)
                
                if let dateObject = dateFormatter.date(from: date) {
                    
                    let minutesFromStartOfDay = Double(currentDate.component(.hour, from: dateObject) * 60 + currentDate.component(.minute, from: dateObject))
                    let timeNormalized = Double(minutesFromStartOfDay / minutesInDay)
                    
                    let dataPoint = DataPoint(time: dateObject,
                                              timeNormalized: timeNormalized,
                                              consumption: consumption,
                                              values: [inverterValue, gridValue, batteryValue] )
                    dataPoints.append(dataPoint)
                } else {
                    print("failed to convert \(date) to minutes")
                }
            } else {
                print("no data for \(date)")
            }
        }
        
        dataPoints = dataPoints.sorted(by: { $0.timeNormalized < $1.timeNormalized })
        return dataPoints
    }
    
    
    static func getPower(jsonData: Data) -> [String: Int?] {
        if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            if let power = json["power"] as? [String : Int?] {
                return power
            }
        }
        return [:]
    }
    
    
    var inverterTimelineCache:[String : Int?] = [:]
    var gridTimelineCache:[String : Int?] = [:]
    var batteryTimelineCache:[String : Int?] = [:]
    private var dataPoints:[DataPoint] = []
    
    func getDataPoints() -> [DataPoint] {
        if (ProcessInfo.processInfo.isSwiftUIPreview) {
            return ModelData.todayTimelineMock()
        }
        return dataPoints
    }
    
    
    /// Timeline for a day
    /// - Parameters:
    ///   - date: day
    ///   - interval: interval between readings
    func pullTimeline(date:Date, interval:Int = 15) async {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: date)
        
//        if !isDateToday(date) {
//            var recordsFetch = FetchDescriptor<DayRecord>(predicate: #Predicate { $0.name == dateString })
//            recordsFetch.fetchLimit = 1
//            recordsFetch.includePendingChanges = true
//            let records = try? modelContext?.fetch(recordsFetch)
//
//            if let found = records?.first {
//                dataPoints = found.dataPoints
//                return
//            }
//        }
        
        if let inverter = self.inverters.first {
            // energy from inverter
            //    https://my.autarco.com/api/site/[api_key]/inverter/[inverter]/power?r=day&d=20231029
            await client.doRequest(path: "inverter/\(inverter)/power?r=day&d=\(dateString)&i=\(interval)") { json in
                if let json = json as? [String: Any] {
                    if let power = json["power"] as? [String : Int?] {
                        self.inverterTimelineCache = power
                    }
                }
            }
        }
        
        await client.doRequest(path: "consumption/power?r=day&d=\(dateString)&i=\(interval)") { json in
            if let json = json as? [String: Any] {
                if let power = json["power"] as? [String: Int?] {
                    self.gridTimelineCache = power
                }
            }
        }
        
        await client.doRequest(path: "batterypack/power?r=day&d=\(dateString)&i=\(interval)") { json in
            if let json = json as? [String: Any] {
                if let power = json["power"] as? [String: Int?] {
                    self.batteryTimelineCache = power
                }
            }
        }
        dataPoints = ModelData.convertTimeline(inverterTimelineCache, gridTimelineCache, batteryTimelineCache)
    }
    
    func inverterTimeline() async -> [String : Int?] {
        if (inverterTimelineCache.count == 0) {
            return ModelData.getPower(jsonData: ModelData.inverterTimelineMock)
        }
        return inverterTimelineCache
    }
    
    func gridTimeline() async -> [String : Int?]  {
        if (gridTimelineCache.count == 0) {
            return ModelData.getPower(jsonData: ModelData.gridTimelineMock)
        }
        return gridTimelineCache
    }
    
    func batteryTimeline() async -> [String : Int?] {
        if (batteryTimelineCache.count == 0) {
            return ModelData.getPower(jsonData: ModelData.batteryTimelineMock)
        }
        return batteryTimelineCache
    }
    
}


extension EnvironmentValues {
    var library: ModelData {
        get { self[ModelDataKey.self] }
        set { self[ModelDataKey.self] = newValue }
    }
}

private struct ModelDataKey: EnvironmentKey {
    static var defaultValue: ModelData = ModelData()
}
