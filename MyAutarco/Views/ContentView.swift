//
//  ContentView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(ModelData.self) private var modelData
    
    @State private var firstStart = true
    
    var body: some View {
        VStack {
            if (modelData.client.isLoggedIn) {
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
        .environment(ModelData())
}
