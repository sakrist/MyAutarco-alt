//
//  HouseView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import SwiftUI
import WidgetKit

struct HouseView: View {
    
    @EnvironmentObject var modelData:ModelData
    @State var selectedDate:Date = Date()
    @State var useTodayDate = true
    
    
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
                    HousePowerNowView()
                        .environmentObject(modelData)
                }
                
                Section("On the date") {
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .onChange(of: selectedDate) { _ in
                            modelData.date = selectedDate
                            self.useTodayDate = isDateToday(selectedDate)
                            calendarId = UUID()
                            Task {
                                await modelData.pullAll()
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
                    
                    
                    HousePowerDateView()
                        .environmentObject(modelData)
                    
                }
            }.refreshable {
                Task {
                    if (self.useTodayDate) {
                        modelData.date = Date()
                    }
                    await modelData.pullAll()
                    
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            
            Spacer()
            
            Button("Logout") {
                Task {
                    modelData.client.logout()
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
        .environmentObject(ModelData())
}
