//
//  TimerActivityAttributes.swift
//  NNTime
//
//  Created by waterbang on 2025/9/10.
//

import Foundation
import ActivityKit

// MARK: - Timer Activity Attributes
/// 计时器 Live Activity 的属性定义
/// 作为 Swift 新手需要了解：ActivityAttributes 协议用于定义 Live Activity 的数据结构
struct TimerActivityAttributes: ActivityAttributes {
    
    /// 内容状态 - 定义 Live Activity 中可以动态更新的数据
    /// Codable: 可以编码/解码，用于数据传输
    /// Hashable: 可以计算哈希值，用于比较和存储
    public struct ContentState: Codable, Hashable {
        /// 计时器开始时间 - 用于计算经过时间
        var startTime: Date
        
        /// 当前状态（运行中/暂停）- 控制计时器是否继续计时
        var isRunning: Bool
        
        /// 暂停时的累计时间（秒）- 用于支持暂停/恢复功能
        var pausedDuration: TimeInterval
    }
    
    // MARK: - 静态配置
    /// 静态配置（创建 Activity 时设置，不会改变）
    /// 计时器名称 - 在 Live Activity 中显示的标题
    var timerName: String
}
