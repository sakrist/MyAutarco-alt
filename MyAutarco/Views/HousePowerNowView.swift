//
//  HousePowerView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 29/10/2023.
//

import SwiftUI


struct HousePowerNowView: View {
    
    var divider = true
    var record: DayRecord
    
    var body: some View {
        VStack {
            HStack {
                Text("PV Panels")
                Spacer()
                Text("\(String(record.now.pvSelf)) (\(String(record.now.pv))) w")
            }
            
            HStack {
                Text("Grid")
                Spacer()
                Text("\(String(record.now.grid)) w")
            }
            
            HStack {
                Text("Battery (\(record.now.battery_charge))%")
                Spacer()
                Text("\(String(record.now.battery)) w")
                    .foregroundStyle( (record.now.battery == 0) ? .primary : (record.now.battery > 0 ) ? Color.green : Color.red )
            }
            
            if (divider) {
                Divider()
            }
            
            HStack {
                Text("Total")
                Spacer()
                Text("\(String(record.now.total)) w")
            }
                
        }
//        .padding([.horizontal, .vertical])
        
    }
}

extension NowPowerStatus {
    fileprivate static var status: NowPowerStatus {
        let intent = NowPowerStatus(pv: 2324, pvSelf: 200, grid: 300, battery: 30, battery_charge: 30, total: 1000)
        return intent
    }
}
extension SummaryPowerStatus {
    fileprivate static var today: SummaryPowerStatus {
        var intent = SummaryPowerStatus()
        intent.pv = 20
        intent.consumed = 13
        return intent
    }
}

#Preview {
    let record = DayRecord(name: "Today", date: .now)
    HousePowerNowView(record: record)
}
