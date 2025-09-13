//
//  NNTimeWidget.swift
//  NNTimeWidget
//
//  Created by waterbang on 2025/9/13.
//

import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Live Activity Widget（灵动岛和锁屏显示）
/// 这是专门用于 Live Activity 的 Widget，支持灵动岛和锁屏显示
struct NNTimeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        // ActivityConfiguration 专门用于配置 Live Activity
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // 锁屏界面显示的内容
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            // 灵动岛显示的内容
            DynamicIsland {
                // 展开状态的各个区域
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "stopwatch")
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
                        Text(context.state.isRunning ? "计时器运行中" : "计时器已暂停")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            } compactLeading: {
                // 紧凑状态左侧显示的图标
                Image(systemName: "clock")
                    .foregroundColor(.blue)
            } compactTrailing: {
                // 紧凑状态右侧显示的时间
                TimerDisplayView(context: context)
                    .font(.caption)
                    .fontWeight(.medium)
            } minimal: {
                // 最小状态显示的图标
                Image(systemName: "clock")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - 锁屏界面视图
/// 在锁屏界面显示的 Live Activity 内容
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "clock")
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
                Text(context.state.isRunning ? "计时中" : "已暂停")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("计时器")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - 时间显示视图
/// 显示计时器时间的视图，会根据 Activity 状态计算正确的时间
struct TimerDisplayView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        Text(elapsedTimeString)
            .monospacedDigit()  // 使用等宽数字字体，让时间显示更稳定
    }
    
    /// 计算并格式化经过的时间
    private var elapsedTimeString: String {
        let state = context.state
        
        if !state.isRunning {
            // 如果计时器已停止，显示暂停时的累计时间
            return formatTimeInterval(state.pausedDuration)
        }
        
        // 计算从开始时间到现在的经过时间
        let now = Date()
        let elapsed = now.timeIntervalSince(state.startTime) + state.pausedDuration
        return formatTimeInterval(elapsed)
    }
    
    /// 将时间间隔格式化为 HH:mm:ss 格式
    /// - Parameter interval: 时间间隔（秒）
    /// - Returns: 格式化后的时间字符串
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600        // 小时数
        let minutes = (totalSeconds % 3600) / 60  // 分钟数
        let seconds = totalSeconds % 60        // 秒数
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

