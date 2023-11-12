//
//  ContentView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(ModelData.self) private var modelData
    @Environment(\.modelContext) private var modelContext
    
    @State private var firstStart = true
    
    var body: some View {
        VStack {
            if (modelData.client.isLoggedIn) {
                HouseView().task {
                    if (firstStart) {
                        modelData.modelContext = modelContext
                        await modelData.pullAllToday()
                        firstStart = false
                    }
                }
            } else {
                LoginView()
            }
            
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
