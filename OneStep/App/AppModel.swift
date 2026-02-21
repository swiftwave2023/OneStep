//
//  AppModel.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI
internal import Combine

// MARK: - App Global State
/// 全局 App 状态模型，管理整个 App 生命周期的共享状态
@MainActor
class AppModel: ObservableObject {
    
    // MARK: - Properties
    
    // MARK: - Window Management
    weak var settingsWindow: NSWindow?
    @Published var shouldOpenSettings: Bool = false
    
    /// 用户是否已登录
    @Published var isLoggedIn: Bool = false
    
    /// 当前是否正在加载
    @Published var isLoading: Bool = false
    
    // Pro Status (mirrored from IAPStore for convenience)
    @Published var isPro: Bool = false
    
    // IAP Store Instance
    let iapStore = IAPStore(productIDs: AppConfig.IAP.allProductIDs)
    
    let appName = "OneStep"
    let appId = "6741484805" // Placeholder, replace with actual ID
    
    // MARK: - Singleton (Optional)
    /// 建议使用 EnvironmentObject 注入，但在某些场景下可使用单例访问
    static let shared = AppModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // 初始化逻辑
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        // 启动时的初始化操作，例如加载本地缓存的用户信息
        print("AppModel initialized")
        
        // Mirror isPro status
        Task { @MainActor in
            iapStore.$isPro.assign(to: &$isPro)
        }
        
        // Forward IAPStore changes to AppModel
        iapStore.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
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
