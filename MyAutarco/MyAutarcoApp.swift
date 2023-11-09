//
//  MyAutarcoApp.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import SwiftUI

@main
struct MyAutarcoApp: App {
    
    @State private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
                .environmentObject(modelData.client)
        }
    }
}

