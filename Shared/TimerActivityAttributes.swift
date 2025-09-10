//
//  TimerActivityAttributes.swift
//  NNTime
//
//  Created by waterbang on 2025/9/10.
//

import Foundation
import ActivityKit

// MARK: - Timer Activity Attributes
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 计时器开始时间
        var startTime: Date
        // 当前状态（运行中/暂停）
        var isRunning: Bool
        // 暂停时的累计时间（秒）
        var pausedDuration: TimeInterval
    }
    
    // 静态配置（创建 Activity 时设置，不会改变）
    var timerName: String
}
