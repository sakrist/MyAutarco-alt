//
//  HousePowerDateView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 06/11/2023.
//

import SwiftUI

struct HousePowerDateView: View {
    @EnvironmentObject var modelData:ModelData
    
    var body: some View {
        VStack {
            HStack {
                Text("PV Panels")
                Spacer()
                Text("\(modelData.statusToday.pv) kWh")
            }
            
            HStack {
                Text("Grid")
                Spacer()
                Text("\(modelData.statusToday.grid) kWh")
            }
            
            HStack {
                Text("Consumed")
                Spacer()
                Text("\(modelData.statusToday.consumed) kWh")
            }
        }
    }
}

#Preview {
    HousePowerDateView()
        .environmentObject(ModelData())
}
