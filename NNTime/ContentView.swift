//
//  ContentView.swift
//  NNTime
//
//  Created by waterbang on 2025/9/9.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // 应用标题
                VStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("NNTime")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("精准计时器")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // 时间显示区域
                VStack(spacing: 16) {
                    Text(timerManager.formattedTime)
                        .font(.system(size: 72, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // 状态指示器
                    HStack(spacing: 8) {
                        Circle()
                            .fill(timerManager.isTimerRunning ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                        
                        Text(timerManager.isTimerRunning ? "运行中" : "已停止")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 控制按钮区域
                VStack(spacing: 20) {
                    // 主要控制按钮
                    HStack(spacing: 30) {
                        // 开始/暂停按钮
                        Button(action: {
                            if timerManager.isTimerRunning {
                                timerManager.pauseTimer()
                            } else if timerManager.elapsedTime > 0 {
                                timerManager.resumeTimer()
                            } else {
                                timerManager.startTimer()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: timerManager.isTimerRunning ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                Text(timerManager.isTimerRunning ? "暂停" : (timerManager.elapsedTime > 0 ? "继续" : "开始"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(width: 120, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(timerManager.isTimerRunning ? Color.orange : Color.blue)
                            )
                        }
                        .disabled(false)
                        
                        // 重置按钮
                        Button(action: {
                            timerManager.resetTimer()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title2)
                                Text("重置")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(width: 120, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(timerManager.canReset ? Color.red : Color.gray)
                            )
                        }
                        .disabled(!timerManager.canReset)
                    }
                    
                    // Live Activity 状态提示
                    if ActivityAuthorizationInfo().areActivitiesEnabled {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Live Activity 已启用")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("请在设置中启用 Live Activity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 50)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
