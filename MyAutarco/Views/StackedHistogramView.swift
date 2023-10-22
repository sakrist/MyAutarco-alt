//
//  StackedHistogramView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import SwiftUI

enum DataType : Int {
    case Inverter = 0
    case Grid = 1
    case Battery = 2
}

struct StackedRectangle: View {
    var dataPoint: DataPoint
    var type: DataType
    var widthPerRectangle: CGFloat
    var maxConsumption: CGFloat
    var size: CGSize

    var body: some View {
        let color: Color

        var value = dataPoint.values[type.rawValue]

            switch type {
            case .Inverter:
                color = .orange
                value = min(value, dataPoint.consumption)
            case .Grid:
                color = .gray
                value = max(0, value) // don't show when giving to grid
            case .Battery:
                color = .green
                value = abs(min(0, value)) // don't show when battery charging
            }

        let height = CGFloat(value) / maxConsumption * size.height

        return Rectangle()
            .fill(color)
            .frame(width: widthPerRectangle, height: height) // Adjust the height scaling factor as needed
    }
}

struct StackedHistogramView: View {
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
            ZStack(alignment:.leading) {
                HStack(alignment: .bottom, spacing: 1) {
                    ForEach(dataPoints, id: \.self) { point in
                        // (geometry.size.width - records) because spacing is 1 in HStack
                        VStack(spacing: 0) {
                            ForEach(0..<point.values.count, id: \.self) { index in
                                StackedRectangle(dataPoint: point,
                                                 type: DataType(rawValue: index)!,
                                                 widthPerRectangle: (geometry.size.width - records) / records,
                                                 maxConsumption: maxConsumption,
                                                 size: geometry.size)
                            }
                        }
                    }
                }

            }
        }
    }
}



#Preview {
    StackedHistogramView(dataPoints: ModelData.todayTimelineMock())
}
