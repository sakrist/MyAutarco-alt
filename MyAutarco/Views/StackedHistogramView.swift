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
    var height: CGFloat
    
    func getColor() -> Color {
        let color: Color
        switch type {
        case .Inverter:
            color = .orange
        case .Grid:
            color = .gray
        case .Battery:
            color = .green
        }
        return color
    }
    
    func getHeight() -> CGFloat {
        var value = dataPoint.values[type.rawValue]
        switch type {
        case .Inverter:
            value = min(value, dataPoint.consumption)
        case .Grid:
            value = max(0, value) // don't show when giving to grid
        case .Battery:
            value = abs(min(0, value)) // don't show when battery charging
        }

        return CGFloat(value) / maxConsumption * height
    }

    var body: some View {
        Rectangle()
            .fill(getColor())
            .frame(width: widthPerRectangle, height: getHeight()) // Adjust the height scaling factor as needed
    }
}

struct StackedHistogramView: View {
    var dataPoints: [DataPoint]
    var showLabels = true
    var maxConsumption: CGFloat
    let minutesInDay: Int = 1440
    let recordInterval: Int = 15
    let records: CGFloat = 96 // minutesInDay / recordInterval
    
    @State var textSize: CGSize = .zero
    
    struct ViewSizeKey: PreferenceKey {
        static var defaultValue: CGSize = .zero

        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    struct ViewGeometry: View {
        var body: some View {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ViewSizeKey.self, value: geometry.size)
            }
        }
    }

    
    init(dataPoints: [DataPoint]) {
        self.dataPoints = dataPoints
        self.maxConsumption = CGFloat( dataPoints.map { $0.consumption }.max() ?? 0 )
    }
    
    init(dataPoints: [DataPoint], showLabels:Bool) {
        self.init(dataPoints:dataPoints)
        self.showLabels = showLabels
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 1) {
                        ForEach(dataPoints, id: \.self) { point in
                            // (geometry.size.width - records) because spacing is 1 in HStack
                            VStack(spacing: 0) {
                                ForEach(0..<point.values.count, id: \.self) { index in
                                    StackedRectangle(dataPoint: point,
                                                     type: DataType(rawValue: index)!,
                                                     widthPerRectangle: (geometry.size.width - records) / records,
                                                     maxConsumption: maxConsumption,
                                                     height: geometry.size.height - textSize.height)
                                }
                            }
                        }
                    }
                    
                    if (showLabels && maxConsumption > 0) {
                        ZStack {
                            VStack {
                                Rectangle()
                                    .fill(.gray)
                                    .frame(height: 1)
                                Spacer()
                            }
                            
                            HStack {
                                Text("0")
                                    .font(.footnote)
                                Spacer()
                            }
                            
                            HStack(alignment: .center, spacing: 0) {
                                ForEach(1..<5) { hour in
                                    Text("\(hour * 6)")
                                        .font(.footnote)
                                        .frame(width: (geometry.size.width) / 4, alignment: .trailing)
                                }
                                .background(ViewGeometry())
                                .onPreferenceChange(ViewSizeKey.self) {
                                    textSize = $0
                                }
                            }
                        }
                    }
                }
                
                if (showLabels && maxConsumption > 0) {
                    HStack(alignment: .bottom, spacing: 0) {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            
                            ForEach((0...Int(maxConsumption / 1000)-1).reversed(), id: \.self) { index in
                                
                                let rheight = 1000 / maxConsumption * (geometry.size.height - textSize.height)
                                
                                Text("\(index+1) -")
                                    .font(.footnote)
                                    .frame(height: rheight, alignment: .top)
                            }
                            
                            Spacer()
                                .frame(width: 10, height: textSize.height, alignment: .bottom)
                        }
                        
                        VStack {
                            Rectangle()
                                .fill(.gray)
                                .frame(width: 1, height: geometry.size.height - textSize.height)
                            Spacer()
                        }
                        
                    }.frame(height: geometry.size.height, alignment: .bottom)
                }
            }
        }
    }
}



#Preview {
    StackedHistogramView(dataPoints: ModelData.todayTimelineMock())
        .frame(width: 300, height: 400)
//        .border(.black)
    
//    StackedHistogramView(dataPoints: ModelData.todayTimelineMock(), showLabels: false)
//        .frame(width: 300, height: 300)
//        .border(.black)
}
