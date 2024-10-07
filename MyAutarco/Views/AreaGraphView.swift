//
//  AreaGraphView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import SwiftUI


struct AreaRectangle: View {
    var dataPoint: DataPoint
    var type: DataType
    var widthPerRectangle: CGFloat
    var maxConsumption: CGFloat
    var size: CGSize

    var body: some View {
        let color: Color

        var value = CGFloat(dataPoint.values[type.rawValue])
        var consumption = CGFloat(dataPoint.consumption)
        
            switch type {
            case .Inverter:
                color = .orange
                value = min(value, consumption)
            case .Grid:
                color = .gray
                value = max(0, value) // don't show when giving to grid
                
                // in case battery got charged from grid
                consumption = (consumption < value) ? value : consumption
            case .Battery:
                color = .green
                value = abs(min(0, value)) // don't show when battery charging
            }

        let height = value / consumption * size.height

        return Rectangle()
            .fill(color)
            .frame(width: max(0, widthPerRectangle), height: max(0, height)) // Adjust the height scaling factor as needed
    }
}

struct AreaGraphView: View {
    var dataPoints: [DataPoint]
    var maxConsumption: CGFloat
    let minutesInDay: Int = 1440
    let recordInterval: Int = 15
    let records: CGFloat = 96 // minutesInDay / recordInterval
    
    init(dataPoints: [DataPoint]) {
        self.dataPoints = dataPoints
        self.maxConsumption = CGFloat( dataPoints.map { $0.consumption }.max() ?? 0 )
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(dataPoints, id: \.self) { point in
                    // (geometry.size.width - records) because spacing is 1 in HStack
                    VStack(spacing: 0) {
                        ForEach(0..<point.values.count, id: \.self) { index in
                            AreaRectangle(dataPoint: point,
                                             type: DataType(rawValue: index)!,
                                             widthPerRectangle: (geometry.size.width) / records,
                                             maxConsumption: maxConsumption,
                                             size: geometry.size)
                        }
                    }
                    .frame(maxHeight: geometry.size.height)
                    .clipped()
                }
            }
        }
    }
}



#Preview {
    AreaGraphView(dataPoints: ModelData.todayTimelineMock())
}
