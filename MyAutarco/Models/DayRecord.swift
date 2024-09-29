//
//  DayRecord.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 09/11/2023.
//

import Foundation
import SwiftData

@Model
final class DayRecord {
    @Attribute(.unique) var name: String
    var date: Date
    var dataPoints = [DataPoint]()
    var now = NowPowerStatus()
    var summary = SummaryPowerStatus()
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
    }
}
