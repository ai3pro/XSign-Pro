//
//  FeatherApp.swift
//  XSign (ESign Remake)
//
//  Created by ThaiSon.
//

import SwiftUI
import Nuke

@main
struct XSignApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let storage = Storage.shared
    @StateObject var downloadManager = DownloadManager.shared
    
    var body: some Scene {
        WindowGroup {
            // Giao diện Tab chuẩn ESign
            TabView {
                // Tab 1: Apps (Đã ký / Thư viện)
                NavigationView {
                    LibraryView(scope: .signed)
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Ứng dụng", systemImage: "square.stack.3d.up.fill")
                }
                
                // Tab 2: Files (File chưa ký / Nhập file)
                NavigationView {
                    LibraryView(scope: .imported)
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Tệp tin", systemImage: "folder.fill")
                }
                
                // Tab 3: Settings
                NavigationView {
                    SettingsView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Cài đặt", systemImage: "gearshape.fill")
                }
            }
            .accentColor(Color(hex: "0096FF")) // Màu xanh ESign
            .environment(\.managedObjectContext, storage.context)
            .environmentObject(downloadManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let fm = FileManager.default
        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let paths = ["Archives", "Certificates", "Signed", "Unsigned"]
            for path in paths {
                try? fm.createDirectory(at: docs.appendingPathComponent(path), withIntermediateDirectories: true)
            }
        }
        return true
    }
}

// Extension màu Hex cho giống ESign
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
