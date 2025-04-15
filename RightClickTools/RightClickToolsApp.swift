//
//  RightClickToolsApp.swift
//  RightClickTools
//
//  Created by kylin on 2025/4/15.
//

import SwiftUI

@main
struct RightClickToolsApp: App {
    // 注入AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 隐藏主窗口
        Settings {
            EmptyView()
        }.windowStyle(HiddenTitleBarWindowStyle())
    }
}
