//
//  WebSearchService.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import Foundation
import SwiftUI
internal import Combine

class WebSearchService: ObservableObject {
    static let shared = WebSearchService()
    
    // MARK: - Published Properties
    @Published var bookmarks: [WebBookmark] = []
    @Published var selectedSearchEngine: SearchEngine = .google {
        didSet {
            UserDefaults.standard.set(selectedSearchEngine.rawValue, forKey: "defaultSearchEngine")
        }
    }
    
    // MARK: - Private Properties
    private let bookmarksKey = "userBookmarks"
    
    // MARK: - Initialization
    private init() {
        loadSettings()
        loadBookmarks()
    }
    
    // MARK: - Settings Management
    private func loadSettings() {
        if let savedEngine = UserDefaults.standard.string(forKey: "defaultSearchEngine"),
           let engine = SearchEngine(rawValue: savedEngine) {
            selectedSearchEngine = engine
        }
    }
    
    // MARK: - Bookmark Management
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([WebBookmark].self, from: data) {
            bookmarks = decoded
        } else {
            // Load default bookmarks if empty
            loadDefaultBookmarks()
        }
    }
    
    private func loadDefaultBookmarks() {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let scriptCode = Locale.current.language.script?.identifier
        let regionCode = Locale.current.language.region?.identifier
        
        // Determine the specific language variant
        // Priority:
        // 1. Specific script (e.g., zh-Hant)
        // 2. Specific region (e.g., pt-BR)
        // 3. Base language (e.g., ja, ko, de)
        
        if languageCode == "zh" {
            if scriptCode == "Hant" || regionCode == "TW" || regionCode == "HK" {
                bookmarks = getTraditionalChineseBookmarks()
            } else {
                bookmarks = getSimplifiedChineseBookmarks()
            }
        } else if languageCode == "ja" {
            bookmarks = getJapaneseBookmarks()
        } else if languageCode == "ko" {
            bookmarks = getKoreanBookmarks()
        } else if languageCode == "ru" {
            bookmarks = getRussianBookmarks()
        } else if languageCode == "pt" && regionCode == "BR" {
            bookmarks = getPortugueseBrazilBookmarks()
        } else if languageCode == "de" {
            bookmarks = getGermanBookmarks()
        } else if languageCode == "fr" {
            bookmarks = getFrenchBookmarks()
        } else if languageCode == "es" {
            bookmarks = getSpanishBookmarks()
        } else if languageCode == "it" {
            bookmarks = getItalianBookmarks()
        } else if languageCode == "hi" {
            bookmarks = getHindiBookmarks()
        } else if languageCode == "ar" {
            bookmarks = getArabicBookmarks()
        } else {
            bookmarks = getEnglishBookmarks()
        }
        
        saveBookmarks()
    }
    
    // MARK: - Localized Bookmark Providers
    
    private func getSimplifiedChineseBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "百度", url: "https://www.baidu.com"),
            WebBookmark(title: "哔哩哔哩", url: "https://www.bilibili.com"),
            WebBookmark(title: "知乎", url: "https://www.zhihu.com"),
            WebBookmark(title: "微博", url: "https://weibo.com"),
            WebBookmark(title: "淘宝", url: "https://www.taobao.com"),
            WebBookmark(title: "京东", url: "https://www.jd.com"),
            WebBookmark(title: "抖音", url: "https://www.douyin.com"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "CSDN", url: "https://www.csdn.net"),
            WebBookmark(title: "掘金", url: "https://juejin.cn"),
            WebBookmark(title: "V2EX", url: "https://www.v2ex.com"),
            WebBookmark(title: "Google", url: "https://www.google.com"),
            WebBookmark(title: "Stack Overflow", url: "https://stackoverflow.com"),
            WebBookmark(title: "码云", url: "https://gitee.com"),
            WebBookmark(title: "腾讯视频", url: "https://v.qq.com"),
            WebBookmark(title: "爱奇艺", url: "https://www.iqiyi.com"),
            WebBookmark(title: "高德地图", url: "https://www.amap.com"),
            WebBookmark(title: "百度贴吧", url: "https://tieba.baidu.com"),
            WebBookmark(title: "小红书", url: "https://www.xiaohongshu.com/explore"),
            WebBookmark(title: "Apple", url: "https://www.apple.com.cn")
        ]
    }
    
    private func getTraditionalChineseBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.com.tw"),
            WebBookmark(title: "Yahoo奇摩", url: "https://tw.yahoo.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "PTT", url: "https://www.ptt.cc"),
            WebBookmark(title: "Mobile01", url: "https://www.mobile01.com"),
            WebBookmark(title: "Dcard", url: "https://www.dcard.tw"),
            WebBookmark(title: "巴哈姆特", url: "https://www.gamer.com.tw"),
            WebBookmark(title: "虾皮购物", url: "https://shopee.tw"),
            WebBookmark(title: "MOMO购物网", url: "https://www.momoshop.com.tw"),
            WebBookmark(title: "PChome", url: "https://www.pchome.com.tw"),
            WebBookmark(title: "联合新闻网", url: "https://udn.com"),
            WebBookmark(title: "ETtoday", url: "https://www.ettoday.net"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/tw"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/tw"),
            WebBookmark(title: "Wikipedia", url: "https://zh.wikipedia.org"),
            WebBookmark(title: "LINE TV", url: "https://www.linetv.tw"),
            WebBookmark(title: "KKBOX", url: "https://www.kkbox.com")
        ]
    }
    
    private func getJapaneseBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Yahoo! JAPAN", url: "https://www.yahoo.co.jp"),
            WebBookmark(title: "Google", url: "https://www.google.co.jp"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.co.jp"),
            WebBookmark(title: "Rakuten", url: "https://www.rakuten.co.jp"),
            WebBookmark(title: "Twitter (X)", url: "https://twitter.com"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "LINE", url: "https://line.me/ja"),
            WebBookmark(title: "Niconico", url: "https://www.nicovideo.jp"),
            WebBookmark(title: "Mercari", url: "https://jp.mercari.com"),
            WebBookmark(title: "Wikipedia", url: "https://ja.wikipedia.org"),
            WebBookmark(title: "Kakaku.com", url: "https://kakaku.com"),
            WebBookmark(title: "Ameba", url: "https://www.ameba.jp"),
            WebBookmark(title: "Livedoor", url: "https://www.livedoor.com"),
            WebBookmark(title: "Goo", url: "https://www.goo.ne.jp"),
            WebBookmark(title: "Note", url: "https://note.com"),
            WebBookmark(title: "Pixiv", url: "https://www.pixiv.net"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/jp"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/jp"),
            WebBookmark(title: "GitHub", url: "https://github.com")
        ]
    }
    
    private func getKoreanBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Naver", url: "https://www.naver.com"),
            WebBookmark(title: "Google", url: "https://www.google.co.kr"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Daum", url: "https://www.daum.net"),
            WebBookmark(title: "Kakao", url: "https://www.kakaocorp.com"),
            WebBookmark(title: "Coupang", url: "https://www.coupang.com"),
            WebBookmark(title: "Namu Wiki", url: "https://namu.wiki"),
            WebBookmark(title: "DC Inside", url: "https://www.dcinside.com"),
            WebBookmark(title: "Tistory", url: "https://www.tistory.com"),
            WebBookmark(title: "Inven", url: "https://www.inven.co.kr"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/kr"),
            WebBookmark(title: "Gmarket", url: "https://www.gmarket.co.kr"),
            WebBookmark(title: "11st", url: "https://www.11st.co.kr"),
            WebBookmark(title: "Nate", url: "https://www.nate.com"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/kr"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Stack Overflow", url: "https://stackoverflow.com"),
            WebBookmark(title: "Ruliweb", url: "https://www.ruliweb.com")
        ]
    }
    
    private func getRussianBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Yandex", url: "https://yandex.ru"),
            WebBookmark(title: "Google", url: "https://www.google.ru"),
            WebBookmark(title: "VK", url: "https://vk.com"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Mail.ru", url: "https://mail.ru"),
            WebBookmark(title: "OK.ru", url: "https://ok.ru"),
            WebBookmark(title: "Avito", url: "https://www.avito.ru"),
            WebBookmark(title: "Wikipedia", url: "https://ru.wikipedia.org"),
            WebBookmark(title: "Gosuslugi", url: "https://www.gosuslugi.ru"),
            WebBookmark(title: "Wildberries", url: "https://www.wildberries.ru"),
            WebBookmark(title: "Ozon", url: "https://www.ozon.ru"),
            WebBookmark(title: "Dzen", url: "https://dzen.ru"),
            WebBookmark(title: "RBC", url: "https://www.rbc.ru"),
            WebBookmark(title: "Kinopoisk", url: "https://www.kinopoisk.ru"),
            WebBookmark(title: "Habr", url: "https://habr.com"),
            WebBookmark(title: "Rutube", url: "https://rutube.ru"),
            WebBookmark(title: "Telegram", url: "https://web.telegram.org"),
            WebBookmark(title: "Sberbank", url: "https://www.sberbank.ru"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/ru"),
            WebBookmark(title: "GitHub", url: "https://github.com")
        ]
    }
    
    private func getPortugueseBrazilBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.com.br"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Globo", url: "https://www.globo.com"),
            WebBookmark(title: "UOL", url: "https://www.uol.com.br"),
            WebBookmark(title: "Mercado Livre", url: "https://www.mercadolivre.com.br"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "WhatsApp Web", url: "https://web.whatsapp.com"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.com.br"),
            WebBookmark(title: "G1", url: "https://g1.globo.com"),
            WebBookmark(title: "Twitter (X)", url: "https://twitter.com"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/br"),
            WebBookmark(title: "Wikipedia", url: "https://pt.wikipedia.org"),
            WebBookmark(title: "Magalu", url: "https://www.magazineluiza.com.br"),
            WebBookmark(title: "Shopee", url: "https://shopee.com.br"),
            WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/br"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Pinterest", url: "https://br.pinterest.com"),
            WebBookmark(title: "TikTok", url: "https://www.tiktok.com")
        ]
    }
    
    private func getGermanBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.de"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.de"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "eBay Kleinanzeigen", url: "https://www.ebay-kleinanzeigen.de"),
            WebBookmark(title: "Wikipedia", url: "https://de.wikipedia.org"),
            WebBookmark(title: "Bild", url: "https://www.bild.de"),
            WebBookmark(title: "Web.de", url: "https://web.de"),
            WebBookmark(title: "GMX", url: "https://www.gmx.net"),
            WebBookmark(title: "T-Online", url: "https://www.t-online.de"),
            WebBookmark(title: "Spiegel", url: "https://www.spiegel.de"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "ZDF", url: "https://www.zdf.de"),
            WebBookmark(title: "ARD", url: "https://www.ard.de"),
            WebBookmark(title: "Focus", url: "https://www.focus.de"),
            WebBookmark(title: "Welt", url: "https://www.welt.de"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/de"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/de"),
            WebBookmark(title: "Twitch", url: "https://www.twitch.tv")
        ]
    }
    
    private func getFrenchBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.fr"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.fr"),
            WebBookmark(title: "Wikipedia", url: "https://fr.wikipedia.org"),
            WebBookmark(title: "Leboncoin", url: "https://www.leboncoin.fr"),
            WebBookmark(title: "Orange", url: "https://www.orange.fr"),
            WebBookmark(title: "Le Monde", url: "https://www.lemonde.fr"),
            WebBookmark(title: "FranceInfo", url: "https://www.francetvinfo.fr"),
            WebBookmark(title: "Le Figaro", url: "https://www.lefigaro.fr"),
            WebBookmark(title: "L'Équipe", url: "https://www.lequipe.fr"),
            WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Twitter (X)", url: "https://twitter.com"),
            WebBookmark(title: "Allociné", url: "https://www.allocine.fr"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/fr"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/fr"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Fnac", url: "https://www.fnac.com"),
            WebBookmark(title: "Cdiscount", url: "https://www.cdiscount.com")
        ]
    }
    
    private func getSpanishBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.es"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Marca", url: "https://www.marca.com"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.es"),
            WebBookmark(title: "El País", url: "https://elpais.com"),
            WebBookmark(title: "AS", url: "https://as.com"),
            WebBookmark(title: "Wikipedia", url: "https://es.wikipedia.org"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Twitter (X)", url: "https://twitter.com"),
            WebBookmark(title: "El Mundo", url: "https://www.elmundo.es"),
            WebBookmark(title: "Milanuncios", url: "https://www.milanuncios.com"),
            WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/es"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/es"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Booking", url: "https://www.booking.com"),
            WebBookmark(title: "TripAdvisor", url: "https://www.tripadvisor.es"),
            WebBookmark(title: "Zara", url: "https://www.zara.com"),
            WebBookmark(title: "AliExpress", url: "https://es.aliexpress.com")
        ]
    }
    
    private func getItalianBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.it"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.it"),
            WebBookmark(title: "Repubblica", url: "https://www.repubblica.it"),
            WebBookmark(title: "Corriere", url: "https://www.corriere.it"),
            WebBookmark(title: "Wikipedia", url: "https://it.wikipedia.org"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Libero", url: "https://www.libero.it"),
            WebBookmark(title: "Il Meteo", url: "https://www.ilmeteo.it"),
            WebBookmark(title: "Gazzetta", url: "https://www.gazzetta.it"),
            WebBookmark(title: "Mediaset", url: "https://www.mediaset.it"),
            WebBookmark(title: "Subito", url: "https://www.subito.it"),
            WebBookmark(title: "eBay", url: "https://www.ebay.it"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com/it"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/it"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Twitter (X)", url: "https://twitter.com"),
            WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
            WebBookmark(title: "Booking", url: "https://www.booking.com")
        ]
    }
    
    private func getHindiBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.co.in"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.in"),
            WebBookmark(title: "Flipkart", url: "https://www.flipkart.com"),
            WebBookmark(title: "Aaj Tak", url: "https://www.aajtak.in"),
            WebBookmark(title: "Dainik Bhaskar", url: "https://www.bhaskar.com"),
            WebBookmark(title: "Wikipedia", url: "https://hi.wikipedia.org"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Twitter (X)", url: "https://twitter.com"),
            WebBookmark(title: "Times of India", url: "https://timesofindia.indiatimes.com"),
            WebBookmark(title: "NDTV", url: "https://www.ndtv.com"),
            WebBookmark(title: "Hotstar", url: "https://www.hotstar.com"),
            WebBookmark(title: "WhatsApp Web", url: "https://web.whatsapp.com"),
            WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/in"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "IRCTC", url: "https://www.irctc.co.in"),
            WebBookmark(title: "Cricbuzz", url: "https://www.cricbuzz.com"),
            WebBookmark(title: "Paytm", url: "https://paytm.com")
        ]
    }
    
    private func getArabicBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.com"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Twitter (X)", url: "https://twitter.com"),
            WebBookmark(title: "Mawdoo3", url: "https://mawdoo3.com"),
            WebBookmark(title: "Kooora", url: "https://www.kooora.com"),
            WebBookmark(title: "Al Jazeera", url: "https://www.aljazeera.net"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.sa"),
            WebBookmark(title: "Wikipedia", url: "https://ar.wikipedia.org"),
            WebBookmark(title: "Haraj", url: "https://haraj.com.sa"),
            WebBookmark(title: "Sabq", url: "https://sabq.org"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Akhbarak", url: "https://akhbarak.net"),
            WebBookmark(title: "Youm7", url: "https://www.youm7.com"),
            WebBookmark(title: "Shahid", url: "https://shahid.mbc.net"),
            WebBookmark(title: "Noon", url: "https://www.noon.com"),
            WebBookmark(title: "Apple", url: "https://www.apple.com/ae"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
            WebBookmark(title: "WhatsApp Web", url: "https://web.whatsapp.com")
        ]
    }
    
    private func getEnglishBookmarks() -> [WebBookmark] {
        return [
            WebBookmark(title: "Google", url: "https://www.google.com"),
            WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
            WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
            WebBookmark(title: "Amazon", url: "https://www.amazon.com"),
            WebBookmark(title: "Wikipedia", url: "https://www.wikipedia.org"),
            WebBookmark(title: "Reddit", url: "https://www.reddit.com"),
            WebBookmark(title: "Netflix", url: "https://www.netflix.com"),
            WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
            WebBookmark(title: "GitHub", url: "https://github.com"),
            WebBookmark(title: "Stack Overflow", url: "https://stackoverflow.com"),
            WebBookmark(title: "X (Twitter)", url: "https://twitter.com"),
            WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
            WebBookmark(title: "Twitch", url: "https://www.twitch.tv"),
            WebBookmark(title: "IMDb", url: "https://www.imdb.com"),
            WebBookmark(title: "CNN", url: "https://www.cnn.com"),
            WebBookmark(title: "Microsoft", url: "https://www.microsoft.com"),
            WebBookmark(title: "Apple", url: "https://www.apple.com"),
            WebBookmark(title: "ChatGPT", url: "https://chat.openai.com"),
            WebBookmark(title: "Discord", url: "https://discord.com"),
            WebBookmark(title: "Spotify", url: "https://open.spotify.com")
        ]
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
        }
    }
    
    func addBookmark(title: String, url: String) {
        let newBookmark = WebBookmark(title: title, url: url)
        bookmarks.append(newBookmark)
        saveBookmarks()
    }
    
    func removeBookmark(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
        saveBookmarks()
    }
    
    func removeBookmark(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        saveBookmarks()
    }
    
    func moveBookmark(from source: IndexSet, to destination: Int) {
        bookmarks.move(fromOffsets: source, toOffset: destination)
        saveBookmarks()
    }
    
    func removeAllBookmarks() {
        bookmarks.removeAll()
        saveBookmarks()
    }
    
    func resetBookmarksToDefault() {
        loadDefaultBookmarks()
    }
    
    // MARK: - Search Logic
    func searchBookmarks(query: String) -> [WebBookmark] {
        guard !query.isEmpty else { return bookmarks }
        return bookmarks.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.url.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getSearchURL(for query: String) -> URL? {
        // If query is a valid URL, return it directly
        if let url = URL(string: query), url.scheme != nil, url.host != nil {
            return url
        }
        
        // If query looks like a domain but missing scheme, prepend https://
        if query.contains(".") && !query.contains(" ") {
             if let url = URL(string: "https://" + query), url.host != nil {
                 return url
             }
        }
        
        // Otherwise use search engine
        return selectedSearchEngine.searchURL(for: query)
    }
    
    // MARK: - Export Logic
    func exportBookmarks() -> String {
        var html = """
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <!-- This is an automatically generated file.
             It will be read and overwritten.
             DO NOT EDIT! -->
        <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
        """
        
        for bookmark in bookmarks {
            html += "\n    <DT><A HREF=\"\(bookmark.url)\">\(bookmark.title)</A>"
        }
        
        html += "\n</DL><p>"
        return html
    }
    
    // MARK: - Import Logic
    func importBookmarks(from fileURL: URL) throws {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let parsedBookmarks = parseNetscapeBookmarks(html: content)
        
        // Merge with existing bookmarks (avoiding exact duplicates by URL)
        let existingURLs = Set(bookmarks.map { $0.url })
        let newBookmarks = parsedBookmarks.filter { !existingURLs.contains($0.url) }
        
        bookmarks.append(contentsOf: newBookmarks)
        saveBookmarks()
    }
    
    private func parseNetscapeBookmarks(html: String) -> [WebBookmark] {
        var results: [WebBookmark] = []
        
        // Simple regex to find <DT><A HREF="...">Title</A> pattern
        // This is a basic implementation and might miss some edge cases
        let pattern = #"<DT><A HREF="([^"]+)"[^>]*>([^<]+)</A>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let nsString = html as NSString
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            if match.numberOfRanges >= 3 {
                let url = nsString.substring(with: match.range(at: 1))
                let title = nsString.substring(with: match.range(at: 2))
                
                results.append(WebBookmark(title: title, url: url))
            }
        }
        
        return results
    }
}
