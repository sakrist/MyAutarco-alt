//
//  HousePowerDateView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 06/11/2023.
//

import SwiftUI

struct HousePowerDateView: View {
    var record: DayRecord
    
    var body: some View {
        VStack {
            HStack {
                Text("PV Panels")
                Spacer()
                Text("\(record.summary.pv) kWh")
            }
            
            HStack {
                Text("Grid")
                Spacer()
                Text("\(record.summary.grid) kWh")
            }
            
            HStack {
                Text("Consumed")
                Spacer()
                Text("\(record.summary.consumed) kWh")
            }
        }
    }
}

#Preview {
    let record = DayRecord(name: "Today", date: .now)
    HousePowerDateView(record: record)
}
