//
//  AppConfig.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import Foundation

// MARK: - App Configuration
/// 管理 App 全局静态配置
struct AppConfig {
    
    // MARK: - App Basic Info
    /// App 名称
    static let appName = "OneStep"
    /// App Group ID (如果有)
    static let appGroupId = "group.com.vibecoding.onestep"
    /// Keychain Service Name
    static let keychainService = "com.vibecoding.onestep.service"
    
    // MARK: - Network Configuration
    /// API 基础地址
    static var apiBaseURL: String {
        #if DEBUG
        return "https://api.dev.vibecoding.com"
        #else
        return "https://api.vibecoding.com"
        #endif
    }
    
    /// 默认超时时间 (秒)
    static let defaultTimeout: TimeInterval = 30.0
    
    // MARK: - Third Party Keys
    /// 示例 SDK Key
    static let exampleSDKKey = ""
    
    // MARK: - UI Constants
    /// 默认动画时长
    static let defaultAnimationDuration: Double = 0.3
}
