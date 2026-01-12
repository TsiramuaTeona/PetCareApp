//
//  WeightChart.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 10.01.26.
//


import SwiftUI
import Charts

struct WeightChart: View {
    // MARK: - Properties
    
    let logs: [HealthLog]
    var onDelete: (HealthLog) -> Void
    
    @State private var selectedLog: HealthLog?
    
    private var sortedLogs: [HealthLog] {
        logs.sorted { $0.date < $1.date }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            chartView
                .overlay(alignment: .top) {
                    if let selected = selectedLog {
                        WeightTooltip(
                            log: selected,
                            onDelete: {
                                onDelete(selected)
                                selectedLog = nil
                            },
                            onClose: {
                                withAnimation { selectedLog = nil }
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(10)
                    }
                }
        }
        .shadowCard()
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Weight History")
                    .font(.appTitle)
                    .foregroundColor(.textPrimary)
                
                if let current = selectedLog?.value ?? sortedLogs.last?.value {
                    Text("\(current, specifier: "%.1f") kg")
                        .font(.appHeader)
                        .foregroundColor(.brandGreen)
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Chart
    
    private var chartView: some View {
        Chart {
            ForEach(sortedLogs) { log in
                if let value = log.value {
                    AreaMark(
                        x: .value("Date", log.date),
                        y: .value("Weight", value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.brandGreen.opacity(0.2), .brandGreen.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Date", log.date),
                        y: .value("Weight", value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.brandGreen)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    
                    PointMark(
                        x: .value("Date", log.date),
                        y: .value("Weight", value)
                    )
                    .symbolSize(150)
                    .foregroundStyle(selectedLog?.id == log.id ? .brandGreen : .white)
                    .annotation(position: .overlay) {
                        Circle()
                            .stroke(Color.brandGreen, lineWidth: 3)
                            .frame(width: 12, height: 12)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .frame(height: 200)
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisTick().foregroundStyle(Color.gray.opacity(0.3))
                AxisValueLabel(format: .dateTime.month().day())
                    .foregroundStyle(Color.textSecondary)
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine().foregroundStyle(Color.gray.opacity(0.1))
                AxisValueLabel()
                    .foregroundStyle(Color.textSecondary)
                    .font(.caption2)
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        guard let date: Date = proxy.value(atX: location.x) else { return }
                        
                        if let closest = sortedLogs.min(by: {
                            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                        }) {
                            withAnimation(.spring()) {
                                if selectedLog?.id == closest.id {
                                    selectedLog = nil
                                } else {
                                    selectedLog = closest
                                }
                            }
                        }
                    }
            }
        }
    }
}
