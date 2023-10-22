//
//  HousePowerView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 29/10/2023.
//

import SwiftUI


struct HousePowerNowView: View {
    
    var divider = true
    
    @Environment(ModelData.self) private var modelData
    
    var body: some View {
        VStack {
            HStack {
                Text("PV Panels")
                Spacer()
                Text("\(String(modelData.status.pvSelf)) (\(String(modelData.status.pv))) w")
            }
            
            HStack {
                Text("Grid")
                Spacer()
                Text("\(String(modelData.status.grid)) w")
            }
            
            HStack {
                Text("Battery (\(modelData.status.battery_charge))%")
                Spacer()
                Text("\(String(modelData.status.battery)) w")
                    .foregroundStyle( (modelData.status.battery == 0) ? .primary : (modelData.status.battery > 0 ) ? Color.green : Color.red )
            }
            
            if (divider) {
                Divider()
            }
            
            HStack {
                Text("Total")
                Spacer()
                Text("\(String(modelData.status.total)) w")
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
extension TodayPowerStatus {
    fileprivate static var today: TodayPowerStatus {
        let intent = TodayPowerStatus(pv: 20, consumed: 13)
        return intent
    }
}

#Preview {
    HousePowerNowView()
        .environment(ModelData())
}
