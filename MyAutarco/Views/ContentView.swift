//
//  ContentView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @Environment(ModelData.self) private var modelData
    @EnvironmentObject var client: AutarcoAPIClient
    
    @State private var firstStart = true
    
    var body: some View {
        VStack {
            if (client.isLoggedIn) {
                HouseView().task {
                    if (firstStart) {
                        await modelData.pullAllToday()
                        firstStart = false
                        DispatchQueue.main.async {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
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
        .environment(ModelData.shared)
        .environmentObject(ModelData.shared.client)
}
