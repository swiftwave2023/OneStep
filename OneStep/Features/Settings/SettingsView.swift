//
//  SettingsView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI
import StoreKit

enum SettingPage: CaseIterable, Identifiable {
    case general
    case fileSearch
    case webSearch
    case iap
    case contactUs
    case rateUs
    
    var id: Self { self }
    
    var nav: SettingNavData {
        switch self {
        case .general:
            return .general
        case .fileSearch:
            return .fileSearch
        case .webSearch:
            return .webSearch
        case .iap:
            return .iap
        case .contactUs:
            return .contactUs
        case .rateUs:
            return .rateUs
        }
    }
}

extension SettingNavData {
    static let fileSearch = Self(icon: "folder", iconColor: .blue, title: "File Search")
    static let webSearch = Self(icon: "globe", iconColor: .cyan, title: "Web Search")
}

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel
    
    var store: IAPStore {
        appModel.iapStore
    }
    
    @State var selectedPage: SettingPage = .general
    @State private var iapProcessing: Bool = false
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            switch selectedPage {
            case .general:
                GeneralPageView()
            case .fileSearch:
                FileSearchSettingsView()
            case .webSearch:
                WebSearchSettingsView()
            case .iap:
                IAPPageView(appName: appModel.appName,
                            isPro: appModel.isPro,
                            isProcessing: $iapProcessing,
                            products: getIAPProductsToDisplay(),
                            purchasedProductIDs: store.purchasedProductIDs,
                            lifetimeProductID: store.products.first(where: { $0.type == .nonConsumable })?.id ?? "product.com.swiftwave.onestep.lifetime",
                            infos: iapInfos,
                            onPurchase: { id in
                                await store.purchase(productId: id)
                            }, onRestore: {
                                await store.restore()
                            })
                .task {
                    await store.refresh()
                }
            case .contactUs:
                ContactUsPageView(appName: appModel.appName, isPro: appModel.isPro)
            case .rateUs:
                // Rate logic handled in onChange, but we need a view here
                Text(NSLocalizedString("Redirecting to App Store...", comment: ""))
                    .onAppear {
                        // In case onChange doesn't catch it or we navigate directly
                        RateUtil.requestReview(id: appModel.appId)
                    }
            }
        }
        .frame(minWidth: 700, maxWidth: 700, minHeight: 620, maxHeight: 620)
        .background(Color(nsColor: .windowBackgroundColor))
        .background(WindowAccessor(callback: { window in
            if let window = window {
                appModel.settingsWindow = window
                window.titlebarAppearsTransparent = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }
        }))
        .onChange(of: selectedPage) { _, newValue in
            if newValue == .rateUs {
                RateUtil.requestReview(id: appModel.appId)
                // Switch back to previous page or stay? 
                // Shortcutly switches back, but let's keep it simple for now or follow Shortcutly behavior
                // For better UX, maybe switch back to general after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedPage = .general
                }
            }
        }
    }
    
    var sidebar: some View {
        VStack {
            List(selection: $selectedPage) {
                ProLogo(appName: appModel.appName, isPro: appModel.isPro)
                    .padding(.bottom)
                ForEach(SettingPage.allCases) { page in
                    NavigationLink(value: page) {
                        SettingNavLabel(nav: page.nav)
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 220, max: 220)
    }
    
    private var iapInfos: [IAPInfo] {
        [
            IAPInfo(icon: "magnifyingglass", title: "Enhanced Search", subTitle: "Search deeper into your system."),
            IAPInfo(icon: "command", title: "Advanced Commands", subTitle: "Execute system commands directly."),
            IAPInfo(icon: "star.fill", title: "Priority Support", subTitle: "Get priority support for any issues."),
            IAPInfo(icon: "sparkles", title: "More Features Coming Soon", subTitle: "Stay tuned for more exciting features.")
        ]
    }
    
    private func getIAPProductsToDisplay() -> [IAPProductDisplay] {
        if !store.products.isEmpty {
            return store.products.map { IAPProductDisplay(product: $0) }
        } else {
            return [
                IAPProductDisplay(id: "product.com.swiftwave.onestep.monthly", displayName: NSLocalizedString("Monthly", comment: ""), displayPrice: "$1.99", type: .autoRenewable, unit: .month),
                IAPProductDisplay(id: "product.com.swiftwave.onestep.yearly", displayName: NSLocalizedString("Yearly", comment: ""), displayPrice: "$9.99", type: .autoRenewable, unit: .year, isFreeTrial: true, trialDays: 7),
                IAPProductDisplay(id: "product.com.swiftwave.onestep.lifetime", displayName: NSLocalizedString("Lifetime", comment: ""), displayPrice: "$29.99", type: .nonConsumable)
            ]
        }
    }
}
