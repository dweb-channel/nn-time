//
//  NNTimeWidget.swift
//  NNTimeWidget
//
//  Created by waterbang on 2025/9/10.
//

import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Live Activity Widget
struct NNTimeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // 锁屏界面显示
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            // 灵动岛显示
            DynamicIsland {
                // 展开状态
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                        Text(context.attributes.timerName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TimerDisplayView(context: context)
                        .font(.title2)
                        .fontWeight(.medium)
                }
                DynamicIslandExpandedRegion(.center) {
                    // 中间区域可以放置控制按钮或其他信息
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Spacer()
                        Text("计时器运行中")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            } compactLeading: {
                // 紧凑状态左侧
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            } compactTrailing: {
                // 紧凑状态右侧 - 显示时间
                // 紧凑状态右侧 - 显示时间
                TimerDisplayView(context: context)
                    .font(.caption)
                    .fontWeight(.medium)
            } minimal: {
                // 最小状态
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - 锁屏界面视图
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.blue)
                Text(context.attributes.timerName)
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Spacer()
                TimerDisplayView(context: context)
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
                Spacer()
            }
            
            HStack {
                Text(context.state.isRunning ? "运行中" : "已暂停")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("开始时间: \(context.state.startTime, formatter: timeFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - 计时器显示视图
struct TimerDisplayView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        Text(formattedElapsedTime)
            .monospacedDigit()
    }
    
    private var formattedElapsedTime: String {
        let currentTime = Date()
        let elapsed: TimeInterval
        
        if context.state.isRunning {
            // 如果正在运行，计算从开始时间到现在的时间，加上之前暂停的累计时间
            elapsed = currentTime.timeIntervalSince(context.state.startTime) + context.state.pausedDuration
        } else {
            // 如果暂停，只显示暂停时的累计时间
            elapsed = context.state.pausedDuration
        }
        
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) % 3600 / 60
        let seconds = Int(elapsed) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - 时间格式化器
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - Widget Bundle
struct NNTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        NNTimeWidgetLiveActivity()
    }
}
