//
//  HouseView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import SwiftUI
import WidgetKit

struct HouseView: View {
    
    @Environment(ModelData.self) private var modelData
    @EnvironmentObject var client: AutarcoAPIClient
    
    @State var selectedDate:Date = Date()
    
    
    // Function to check if a date is today
    func isDateToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let otherDate = calendar.startOfDay(for: date)
        return today == otherDate
    }
    
    struct CenterProgressView: View {
        var body: some View {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }
    
    @State var calendarId: UUID = UUID()
    
    var body: some View {
        VStack {
            
            List {
                
                Section("Now") {
                    HousePowerNowView(record: modelData.today)
                }
                
                Section("On the date") {
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .onChange(of: selectedDate) { _, _ in
                            calendarId = UUID()
                            Task {
                                await modelData.pull(date:selectedDate)
                            }
                        }
                        .id(calendarId)
                                        
                    
                    VStack {
                        ZStack {
                            StackedHistogramView(dataPoints: modelData.getDataPoints())
                            if (modelData.isLoading) {
                                CenterProgressView()
                            }
                        }
                    }.frame(height: 230)
                    
                    VStack {
                        ZStack {
                            AreaGraphView(dataPoints: modelData.getDataPoints())
                            if (modelData.isLoading) {
                                CenterProgressView()
                            }
                        }
                    }.frame(height: 50)
                    
                    
                    HousePowerDateView(record: modelData.today)
                }
            }.refreshable {
                Task {
                    selectedDate = Date()
                    await modelData.pullAllToday()
                    
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            
            Spacer()
            
            Button("Logout") {
                client.isLoggedIn = false
                Task {
                    client.logout()
                }
            }.buttonStyle(.bordered)
                .foregroundStyle(.red)
            
            
            Text(modelData.client.errorMessage)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    HouseView()
        .environment(ModelData.shared)
}
