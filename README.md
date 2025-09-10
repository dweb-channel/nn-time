# NNTime - 精准计时器应用

## 功能特性

- ✅ 精确到秒的计时器显示（HH:mm:ss 格式）
- ✅ Live Activity 支持，在锁屏界面显示计时器
- ✅ 灵动岛支持，在支持的设备上显示实时计时
- ✅ 现代化的 SwiftUI 界面设计
- ✅ 开始、暂停、继续、重置功能


## Live Activity 功能

- **锁屏显示**：计时器运行时会在锁屏界面显示实时时间
- **灵动岛显示**：在支持灵动岛的设备上（iPhone 14 Pro 及以上），时间会显示在灵动岛区域
- **实时更新**：时间每秒自动更新，无需手动刷新

## 系统要求

- iOS 16.1 或更高版本
- Xcode 14.1 或更高版本
- 支持 Live Activity 的设备

## 配置说明

### 主应用配置 (NNTime/Info.plist)
- `NSSupportsLiveActivities`: 启用 Live Activity 支持
- `NSSupportsLiveActivitiesFrequentUpdates`: 允许频繁更新

### Widget Extension 配置 (NNTimeWidget/Info.plist)
- `NSSupportsLiveActivities`: Widget 支持 Live Activity
- `NSExtensionPointIdentifier`: WidgetKit 扩展标识符
# nn-time
