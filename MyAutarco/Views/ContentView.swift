//
//  ContentView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var client: AutarcoAPIClient
    
    @State private var firstStart = true
    
    var body: some View {
        VStack {
            if (client.isLoggedIn) {
                HouseView().task {
                    if (firstStart) {
                        await modelData.pullAll()
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
        .environmentObject(ModelData())
}
