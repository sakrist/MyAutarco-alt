//
//  DataPoint.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 07/11/2023.
//

import Foundation

// values contains 3 values:
// inverter - directing electricity from PV panels
// grid - is main electricity source (can be negative value when inverter producing too much power)
// battery - can be positive or negative, depending on it is charging or discharging
struct DataPoint : Hashable, Codable {
    var time: Date
    var timeNormalized: Double // value from 0 to 1
    var consumption: Int // sum of 3 input to calculate what house is consuming atm,  max(0, inverterValue + gridValue - batteryValue)
    var values: [Int] // [inverter, grid, battery]

    func getValue(at index:Int) -> Int {
        var value:Int = values[index]
        switch index {
        case 0:
            value = min(value, consumption)
        case 1:
            value = max(0, value) // don't show when giving to grid
        case 2:
            value = abs(min(0, value)) // don't show when battery charging
        default:
            break
        }
        return value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(time)
    }

    static func == (lhs: DataPoint, rhs: DataPoint) -> Bool {
        return lhs.time == rhs.time
    }
}
