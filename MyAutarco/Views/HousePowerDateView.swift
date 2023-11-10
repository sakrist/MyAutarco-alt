//
//  HousePowerDateView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 06/11/2023.
//

import SwiftUI

struct HousePowerDateView: View {
    @Environment(ModelData.self) private var modelData
    
    var body: some View {
        VStack {
            HStack {
                Text("PV Panels")
                Spacer()
                Text("\(modelData.totalStatus.pv) kWh")
            }
            
            HStack {
                Text("Grid")
                Spacer()
                Text("\(modelData.totalStatus.grid) kWh")
            }
            
            HStack {
                Text("Consumed")
                Spacer()
                Text("\(modelData.totalStatus.consumed) kWh")
            }
        }
    }
}

#Preview {
    HousePowerDateView()
        .environment(ModelData())
}
