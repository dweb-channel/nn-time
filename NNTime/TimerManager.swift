//
//  TimerManager.swift
//  NNTime
//
//  Created by waterbang on 2025/9/10.
//

import Foundation
import ActivityKit  // 用于 Live Activity 功能
import Combine      // 用于响应式编程
import SwiftUI      // 用于 UI 相关功能


/// 计时器管理器类 - 负责管理计时器的状态和 Live Activity
/// @MainActor 确保所有操作都在主线程执行，保证 UI 更新的安全性
@MainActor
class ClockManager: ObservableObject {
    
    // MARK: - 发布属性（Published Properties）
    // 这些属性会在改变时自动通知 UI 更新
    
    /// 计时器是否正在运行
    @Published var isRunning = false
    
    /// 当前显示的时间字符串（格式：HH:mm:ss）
    @Published var currentTime = "00:00:00"
    
    // MARK: - 私有属性（Private Properties）
    // 这些属性只在类内部使用
    
    /// 系统定时器，用于每秒更新时间显示
    private var timer: Timer?
    
    /// Live Activity 实例，用于在锁屏和灵动岛显示计时器
    private var activity: Activity<TimerActivityAttributes>?
    
    /// 计时器开始的时间点
    private var startTime: Date?
    
    /// 暂停时累计的时间长度（秒）
    private var pausedDuration: TimeInterval = 0

    /// 初始化方法 - 创建 ClockManager 实例时自动调用
    init() {
        updateCurrentTime()  // 初始化时更新一次时间显示
    }

    // MARK: - 计时器控制方法（Clock Control Methods）

    /// 启动计时器显示
    /// 这个方法会：1. 记录开始时间 2. 启动内部定时器 3. 创建 Live Activity
    func start() {
        // guard 语句：如果已经在运行，直接返回，避免重复启动
        guard !isRunning else { return }
        
        isRunning = true           // 设置运行状态为 true
        startTime = Date()         // 记录当前时间作为开始时间
        
        // 启动内部计时器用于每秒更新UI显示
        startInternalTimer()
        
        // 启动 Live Activity 显示
        startLiveActivity()
    }

    /// 停止计时器显示
    /// 这个方法会：1. 保存已运行时间 2. 停止定时器 3. 结束 Live Activity
    func stop() {
        // 如果正在运行且有开始时间，计算并累加运行时间
        if isRunning, let start = startTime {
            // timeIntervalSince 计算从开始时间到现在的秒数
            pausedDuration += Date().timeIntervalSince(start)
        }
        
        isRunning = false     // 设置运行状态为 false
        startTime = nil       // 清空开始时间
        
        // 停止内部定时器，避免继续更新UI
        stopInternalTimer()
        
        // 暂时禁用 Live Activity，因为需要正确配置 Widget Extension
        // endLiveActivity()
    }
    
    /// 重置计时器到初始状态
    /// 这会清除所有累计时间，回到 00:00:00
    func reset() {
        stop()                    // 先停止计时器
        pausedDuration = 0        // 清零累计时间
        updateCurrentTime()       // 更新显示为 00:00:00
    }

    // MARK: - 私有定时器方法（Private Timer Methods）
    
    /// 启动内部定时器 - 每秒执行一次更新
    private func startInternalTimer() {
        // 创建一个每1秒重复执行的定时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // 使用 Task 在主线程异步执行UI更新
            // [weak self] 避免循环引用导致内存泄漏
            Task { @MainActor [weak self] in
                await self?.updateCurrentTime()                // 暂时禁用 Live Activity 更新
                // self?.updateLiveActivity()         // 更新 Live Activity 状态
            }
        }
    }

    /// 停止内部定时器
    private func stopInternalTimer() {
        timer?.invalidate()  // 停止定时器
        timer = nil          // 清空定时器引用
    }

    private func updateCurrentTime() async {
        await MainActor.run {
            self.updateCurrentTimeSync()
        }
    }
    
    private func updateCurrentTime() {
        updateCurrentTimeSync()
    }
    
    private func updateCurrentTimeSync() {
        if isRunning, let start = startTime {
            // 计算经过的时间
            let elapsed = Date().timeIntervalSince(start) + pausedDuration
            currentTime = formatTimeInterval(elapsed)
        } else {
            // 显示暂停时的累计时间
            currentTime = formatTimeInterval(pausedDuration)
        }
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Live Activity 方法（Live Activity Methods）

    /// 启动 Live Activity（灵动岛和锁屏显示）
    /// 注意：Live Activity 需要在 Widget Extension target 中运行
    private func startLiveActivity() {
        // 检查系统是否启用了 Live Activities 功能
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities 未启用 - 请在设置中开启")
            return
        }
        
        // 创建 Activity 的属性配置（静态信息，创建后不会改变）
        let attributes = TimerActivityAttributes(timerName: "计时器")
        
        // 创建 Activity 的内容状态（动态信息，可以更新）
        let contentState = TimerActivityAttributes.ContentState(
            startTime: startTime ?? Date(),    // 开始时间
            isRunning: isRunning,              // 是否正在运行
            pausedDuration: pausedDuration     // 暂停累计时间
        )

        do {
            // 请求创建 Live Activity
            // 注意：这里会出现 unsupportedTarget 错误，因为需要 Widget Extension
            activity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: contentState, staleDate: nil),
                pushType: nil
            )
            print("Live Activity 已启动")
        } catch {
            print("启动 Live Activity 失败: \(error)")
            // 如果是 unsupportedTarget 错误，说明需要创建独立的 Widget Extension target
            if error.localizedDescription.contains("unsupportedTarget") {
                print("错误原因：需要创建独立的 Widget Extension target")
            }
        }
    }

    private func updateLiveActivity() {
        guard let activity = activity else { return }

        let contentState = TimerActivityAttributes.ContentState(
            startTime: startTime ?? Date(),
            isRunning: isRunning,
            pausedDuration: pausedDuration
        )

        Task {
            await activity.update(ActivityContent(state: contentState, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = activity else { return }

        let contentState = TimerActivityAttributes.ContentState(
            startTime: Date(),
            isRunning: false,
            pausedDuration: 0
        )

        Task {
            await activity.end(ActivityContent(state: contentState, staleDate: nil), dismissalPolicy: .immediate)
        }

        self.activity = nil
    }

    // MARK: - Computed Properties

    var canStart: Bool {
        return !isRunning
    }

    var canStop: Bool {
        return isRunning
    }
}
