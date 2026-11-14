//
//  iOSStudioApp.swift
//  iOSStudio
//

import SwiftUI

@main
struct iOSStudioApp: App {
    @StateObject private var theme = ThemeManager.shared
    @StateObject private var storage = AppStorageManager.shared
    
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                HomeDashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                NavigationView {
                    WallpaperStudioView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Wallpapers", systemImage: "photo.on.rectangle.angled")
                }
                .tag(1)
                
                NavigationView {
                    TendiesManagerView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Tendies", systemImage: "archivebox.fill")
                }
                .tag(2)
                
                NavigationView {
                    IconStudioView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Icons", systemImage: "square.grid.2x2.fill")
                }
                .tag(3)
                
                NavigationView {
                    WidgetStudioView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Widgets", systemImage: "square.text.square.fill")
                }
                .tag(4)
                
                NavigationView {
                    SettingsRootView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
            }
            .accentColor(theme.currentAccent)
            .preferredColorScheme(theme.colorScheme)
            .onOpenURL { url in
                handleIncomingDeepLink(url)
            }
        }
    }
    
    private func handleIncomingDeepLink(_ url: URL) {
        let scheme = url.scheme?.lowercased()
        guard scheme == "iosstudio" else { return }
        
        let host = url.host?.lowercased() ?? ""
        switch host {
        case "home":
            selectedTab = 0
        case "wallpapers", "wallpaper":
            selectedTab = 1
        case "tendies":
            selectedTab = 2
        case "icons", "icon":
            selectedTab = 3
        case "widgets", "widget":
            selectedTab = 4
        case "settings":
            selectedTab = 5
        default:
            selectedTab = 0
        }
        storage.logOperation("Handled deep link: \(url.absoluteString)")
    }
}

