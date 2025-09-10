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
class ClockManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isRunning = false
    @Published var currentTime = "00:00:00"
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var activity: Activity<TimerActivityAttributes>?
    
    init() {
        updateCurrentTime()
    }
    
    // MARK: - Clock Control Methods
    
    /// 启动时钟显示
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        
        // 启动内部计时器用于更新UI
        startInternalTimer()
        
        // 启动 Live Activity
        startLiveActivity()
    }
    
    /// 停止时钟显示
    func stop() {
        isRunning = false
        
        // 停止内部计时器
        stopInternalTimer()
        
        // 结束 Live Activity
        endLiveActivity()
    }
    
    // MARK: - Private Timer Methods
    
    private func startInternalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateCurrentTime()
            }
        }
    }
    
    private func stopInternalTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCurrentTime() async {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = "HH:mm:ss"
        currentTime = formatter.string(from: now)
    }
    
    private func updateCurrentTime() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = "HH:mm:ss"
        currentTime = formatter.string(from: now)
    }
    
    // MARK: - Live Activity Methods
    
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities 未启用")
            return
        }
        
        let attributes = TimerActivityAttributes(timerName: "时钟")
        let contentState = TimerActivityAttributes.ContentState(
            startTime: Date(),
            isRunning: isRunning,
            pausedDuration: 0
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
            startTime: Date(),
            isRunning: isRunning,
            pausedDuration: 0
        )
        
        Task {
            await activity.update(using: contentState)
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
            await activity.end(using: contentState, dismissalPolicy: .immediate)
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
