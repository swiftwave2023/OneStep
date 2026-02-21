//
//  AppModel.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI
import Combine

// MARK: - App Global State
/// 全局 App 状态模型，管理整个 App 生命周期的共享状态
class AppModel: ObservableObject {
    
    // MARK: - Properties
    
    /// 用户是否已登录
    @Published var isLoggedIn: Bool = false
    
    /// 当前是否正在加载
    @Published var isLoading: Bool = false
    
    // MARK: - Singleton (Optional)
    /// 建议使用 EnvironmentObject 注入，但在某些场景下可使用单例访问
    static let shared = AppModel()
    
    private init() {
        // 初始化逻辑
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        // 启动时的初始化操作，例如加载本地缓存的用户信息
        print("AppModel initialized")
    }
    
    /// 模拟登录操作
    func login() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoggedIn = true
            self.isLoading = false
        }
    }
    
    /// 退出登录
    func logout() {
        isLoggedIn = false
        // 清理数据
    }
}
