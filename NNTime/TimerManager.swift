//
//  TimerManager.swift
//  NNTime
//
//  Created by waterbang on 2025/9/10.
//

import Foundation
import ActivityKit
import Combine
import SwiftUI

@MainActor
class StopwatchManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var formattedTime = "00:00:00"
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?
    private var pausedDuration: TimeInterval = 0
    private var activity: Activity<TimerActivityAttributes>?
    
    // MARK: - Stopwatch Control Methods
    
    /// 启动秒表
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        startTime = Date()
        
        // 启动内部计时器用于更新UI
        startInternalTimer()
        
        // 启动 Live Activity
        startLiveActivity()
    }
    
    /// 暂停秒表
    func pause() {
        guard isRunning else { return }
        
        isRunning = false
        
        // 计算并保存暂停时的累计时间
        if let startTime = startTime {
            pausedDuration += Date().timeIntervalSince(startTime)
        }
        
        // 停止内部计时器
        stopInternalTimer()
        
        // 更新 Live Activity
        updateLiveActivity()
    }
    
    /// 继续秒表
    func resume() {
        guard !isRunning else { return }
        
        isRunning = true
        startTime = Date() // 重新设置开始时间
        
        // 重启内部计时器
        startInternalTimer()
        
        // 更新 Live Activity
        updateLiveActivity()
    }
    
    /// 重置秒表
    func reset() {
        isRunning = false
        elapsedTime = 0
        pausedDuration = 0
        startTime = nil
        formattedTime = "00:00:00"
        
        // 停止内部计时器
        stopInternalTimer()
        
        // 结束 Live Activity
        endLiveActivity()
    }
    
    // MARK: - Private Timer Methods
    
    private func startInternalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateElapsedTime()
            }
        }
    }
    
    private func stopInternalTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() async {
        guard let startTime = startTime else { return }
        
        if isRunning {
            elapsedTime = Date().timeIntervalSince(startTime) + pausedDuration
        } else {
            elapsedTime = pausedDuration
        }
        
        updateFormattedTime()
    }
    
    private func updateFormattedTime() {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) % 3600 / 60
        let seconds = Int(elapsedTime) % 60
        
        formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Live Activity Methods
    
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities 未启用")
            return
        }
        
        let attributes = TimerActivityAttributes(timerName: "秒表")
        let contentState = TimerActivityAttributes.ContentState(
            startTime: startTime ?? Date(),
            isRunning: isRunning,
            pausedDuration: pausedDuration
        )
        
        do {
            activity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            print("Live Activity 已启动")
        } catch {
            print("启动 Live Activity 失败: \(error)")
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
            await activity.update(using: contentState)
        }
    }
    
    private func endLiveActivity() {
        guard let activity = activity else { return }
        
        let contentState = TimerActivityAttributes.ContentState(
            startTime: startTime ?? Date(),
            isRunning: false,
            pausedDuration: pausedDuration
        )
        
        Task {
            await activity.end(using: contentState, dismissalPolicy: .immediate)
        }
        
        self.activity = nil
    }
    
    // MARK: - Computed Properties
    
    var canStart: Bool {
        return !isRunning
    }
    
    var canPause: Bool {
        return isRunning
    }
    
    var canReset: Bool {
        return elapsedTime > 0 || isRunning
    }
}
