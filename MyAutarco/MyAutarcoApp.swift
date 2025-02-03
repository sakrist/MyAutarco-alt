//
//  MyAutarcoApp.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import SwiftUI
import SwiftData

@main
struct MyAutarcoApp: App {
    
    let modelData = ModelData.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DayRecord.self)
        .environment(modelData)
        .environmentObject(modelData.client)
    }

}

