//
//  StackedHistogramView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import SwiftUI
import Charts

enum DataType : Int {
    case Inverter = 0
    case Grid = 1
    case Battery = 2
}

struct StackedHistogramView: View {
    var dataPoints: [DataPoint]
    var showLabels = true
    var maxConsumption: Double
    let watt:Double =  1000.0
    
    init(dataPoints: [DataPoint]) {
        self.dataPoints = dataPoints
        self.maxConsumption = Double( dataPoints.map { $0.consumption }.max() ?? 0 )
    }
    
    init(dataPoints: [DataPoint], showLabels:Bool) {
        self.init(dataPoints:dataPoints)
        self.showLabels = showLabels
    }
    
    let colors:[Color] = [.orange, .gray, .green]
    
    var body: some View {
        let startOfDay = Calendar.current.startOfDay(for: dataPoints.first?.time ?? Date()) // 00:00
        let endOfDay = startOfDay.addingTimeInterval(24 * 60 * 60) // 24 hours later
                
        
        Chart {
            ForEach(dataPoints, id: \.self) { point in
                ForEach((0..<point.values.count).reversed(), id: \.self) { index in
                    let value = Double(point.getValue(at:index)) / watt
                    // 900 seconds in 15 minutes
                    BarMark(
                        x: .value("Time", point.time ..< point.time.advanced(by: 900)),
                        y: .value("Consumption", value)
                    ).foregroundStyle(colors[index])
                }
            }
        }
        .chartXScale(domain: startOfDay...endOfDay)
        .chartYScale(domain: 0...Double(maxConsumption / watt))
        .chartYAxis {
            if showLabels {
                AxisMarks(values: .automatic) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            } else {
                AxisMarks(values: .automatic) {
                    AxisGridLine() // Only show grid lines, no labels
                }
            }
        }
        .chartXAxis {
            if showLabels {
                AxisMarks(values: .automatic) {
                    AxisValueLabel() // Show labels
                    AxisGridLine()
                }
            } else {
                AxisMarks(values: .automatic) {
                    AxisGridLine() // Only show grid lines, no labels
                }
            }
        }
    }
}



#Preview {
    StackedHistogramView(dataPoints: ModelData.todayTimelineMock())
}


#Preview {
    StackedHistogramView(dataPoints: ModelData.todayTimelineMock(), showLabels: false)
}
