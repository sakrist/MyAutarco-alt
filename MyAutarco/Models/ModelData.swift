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

struct TotalPowerStatus : Codable {
    var pv:Int = 0 // today PV produced in kWh
    var grid:Int = 0
    var consumed:Int = 0 // today PV + Grid + Battery consumed in kWh
}


@Observable final class ModelData {
    
    public var modelContext: ModelContext?
    
    var client = AutarcoAPIClient()
    
    var status = NowPowerStatus()
    var totalStatus = TotalPowerStatus()
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
    
    func pullAll() async {
        self.isLoading = true
        
        if (client.public_key.isEmpty) {
            await client.getPublicKey()
        }
        await power()
        await energy()
        
        await pull(date: selectedDate)
        self.isLoading = false
    }

    func pull(date:Date) async {
        self.isLoading = true
        defer {
            self.isLoading = false
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
                self.totalStatus = found.powerStatus
                self.dataPoints = found.dataPoints
                self.isLoading = false
                return
            }
        }
        
        await consumption(date: date)
        await pullTimeline(date: date)
        
        if !isToday, let modelContext = modelContext {
            let record = DayRecord(name: dateString, date: date)
            record.dataPoints = dataPoints
            record.powerStatus = totalStatus
            modelContext.insert(record)
            try? modelContext.save()
        }
    }
    
    func power() async {
        await client.doRequest(path: "kpis/power") { json in
            if let json = json as? [String: Any] {
                self.status.pv = Int(json["pv_now"] as? Int ?? 0)
                self.status.grid = Int(json["consumed_now"] as? Int ?? 0)
                self.status.battery = Int(json["battery_now"] as? Int ?? 0)
                
                self.status.total = max(0, self.status.pv + self.status.grid - self.status.battery)
                self.status.pvSelf = max(0, min(self.status.pv + self.status.grid, self.status.pv));
                
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
                self.status.battery_charge = Int(json["battery_soc"] as? Int ?? 0)
            } else {
                self.client.errorMessage = "Failed to parse kpis/energy"
            }
        }
    }
    
    // MARK: - consumption today
    
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
                        self.totalStatus.pv = pv
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
                    self.totalStatus.grid = grid
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
        self.totalStatus.consumed = consumed
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
            if let inverterValue = inverter[date] as? Int, 
                let gridValue = grid[date] as? Int,
                let batteryValue = battery[date] as? Int {
                
                let consumption = max(0, inverterValue + gridValue - batteryValue)
                let batteryValue = batteryValue
                let inverterValue = max(0, inverterValue)
                let gridValue = gridValue
                
                if let dateObject = dateFormatter.date(from: date) {
                    
                    let minutesFromStartOfDay = Double(currentDate.component(.hour, from: dateObject) * 60 + currentDate.component(.minute, from: dateObject))
                    let timeNormalized = Double(minutesFromStartOfDay / minutesInDay)
                    
                    let dataPoint = DataPoint(time: dateObject,
                                              timeNormalized: timeNormalized,
                                              consumption: consumption,
                                              values: [inverterValue, gridValue, batteryValue] )
                    dataPoints.append(dataPoint)
                }
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
    
    func pullTimeline(date:Date) async {
        
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
            await client.doRequest(path: "inverter/\(inverter)/power?r=day&d=\(dateString)") { json in
                if let json = json as? [String: Any] {
                    if let power = json["power"] as? [String : Int?] {
                        self.inverterTimelineCache = power
                    }
                }
            }
        }
        
        await client.doRequest(path: "consumption/power?r=day&d=\(dateString)") { json in
            if let json = json as? [String: Any] {
                if let power = json["power"] as? [String: Int?] {
                    self.gridTimelineCache = power
                }
            }
        }
        
        await client.doRequest(path: "batterypack/power?r=day&d=\(dateString)") { json in
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
