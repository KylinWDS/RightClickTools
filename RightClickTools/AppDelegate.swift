//
//  AppDelegate.swift
//  RightClickTools
//
//  Created by kylin on 2025/4/15.
//

//import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers
import Carbon
import UserNotifications

var gHotKeySignature: OSType = 0
var gHotKeyID: UInt32 = 0
var gAppDelegate: AppDelegate? = nil

// 定义一个不捕获上下文的事件处理函数
func hotKeyEventHandler(_ nextHandler: EventHandlerCallRef?, _ theEvent: EventRef?, _ userData: UnsafeMutableRawPointer?) -> OSStatus {
    var hotKeyID = EventHotKeyID()
    GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
    
    if hotKeyID.signature == gHotKeySignature && hotKeyID.id == gHotKeyID {
        DispatchQueue.main.async {
            print("热键被按下，调用showMenuAtMousePosition")
            gAppDelegate?.showMenuAtMousePosition()
        }
    }
    
    return noErr
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var rightClickMonitor: Any? = nil
    var isRightClickEnabled: Bool = false
    
    // 定义类型更明确的菜单项数组
    let menuItems: [[String: Any]] = [
        ["title": "复制文件路径", "action": #selector(copyFilePath)],
        ["title": "用Sublime打开", "action": #selector(openWithSublime)],
        ["title": "在此打开终端", "action": #selector(openTerminalHere)],
        ["title": "切换隐藏文件", "action": #selector(toggleHiddenFiles)],
        ["title": "新建文件", "submenu": [
            ["title": "新建TXT", "action": #selector(createTXT)],
            ["title": "新建Markdown", "action": #selector(createMarkdown)],
            ["title": "新建Word", "action": #selector(createWord)],
            ["title": "新建Excel", "action": #selector(createExcel)],
            ["title": "新建PPT", "action": #selector(createPPT)]
        ] as [[String: Any]]]
    ]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置全局AppDelegate引用
        gAppDelegate = self
        
        // 设置状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "contextualmenu", accessibilityDescription: "右键工具")
            button.toolTip = "右键工具 - 点击显示功能菜单"
        }
        
        // 构建菜单
        buildMenu()
        
        // 设置状态栏图标点击事件
        statusItem.button?.action = #selector(statusItemClicked)
        
        // 注册全局热键 (Option+Command+R)
        registerHotKey()
        
        // 检查模板文件
        checkTemplates()
        
        // 设置首次启动提示
        showFirstLaunchNotice()
    }
    
    func showFirstLaunchNotice() {
        let hasShownFirstLaunch = UserDefaults.standard.bool(forKey: "HasShownFirstLaunchNotice")
        
        if !hasShownFirstLaunch {
            let alert = NSAlert()
            alert.messageText = "右键工具已启动"
            alert.informativeText = "由于系统限制，此工具无法直接添加到Finder原生右键菜单中。\n\n您可以通过以下方式使用工具：\n\n1. 点击状态栏图标\n2. 使用快捷键 Option+Command+R\n\n若要在右键点击位置显示菜单，请在设置中启用'覆盖右键菜单'功能，但请注意这会替代系统右键菜单。"
            alert.addButton(withTitle: "了解")
            alert.runModal()
            
            UserDefaults.standard.set(true, forKey: "HasShownFirstLaunchNotice")
        }
    }
    
    func registerHotKey() {
        print("开始注册热键 Option+Command+R")
        // 注册Option+Command+R热键
        var hotKeyRef: EventHotKeyRef?
        
        // 使用四字符代码创建OSType（更安全的方法）
        // 简化OSType计算方式以避免编译器超时
        let signature: OSType = 0x52435448 // "RCTH" 的ASCII值
        
        let hotKeyID = EventHotKeyID(signature: signature, id: 1)
        
        // 存储签名和ID为全局变量，以便在事件处理函数中使用
        gHotKeySignature = signature
        gHotKeyID = 1
        
        let modifiers: UInt32 = UInt32(optionKey | cmdKey)
        let keyCode = UInt32(kVK_ANSI_R) // R键
        
        let registerResult = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerResult != noErr {
            print("无法注册热键，错误码: \(registerResult)")
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "热键注册失败"
                alert.informativeText = "无法注册Option+Command+R热键，可能是因为该热键已被其他应用占用。请尝试使用状态栏图标访问菜单，或者关闭可能占用此热键的应用程序后重新启动本应用。"
                alert.addButton(withTitle: "确定")
                alert.runModal()
            }
        } else {
            print("热键注册成功")
        }
        
        // 安装事件处理器
        let eventSpec = [
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        ]
        
        let installResult = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyEventHandler,
            eventSpec.count,
            eventSpec,
            nil,
            nil
        )
        
        if installResult != noErr {
            print("安装事件处理器失败，错误码: \(installResult)")
        } else {
            print("事件处理器安装成功")
        }
    }
    
    func showMenuAtMousePosition() {
        // 先尝试激活Finder
        let activateScript = """
        tell application "Finder"
            activate
        end tell
        """
        
        var error: NSDictionary?
        NSAppleScript(source: activateScript)?.executeAndReturnError(&error)
        
        if let error = error {
            print("激活Finder失败: \(error)")
        }
        
        // 添加短暂延迟，确保Finder已被激活
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            let mouseLocation = NSEvent.mouseLocation
            print("在位置显示菜单: \(mouseLocation)")
            self?.showMenu(at: mouseLocation)
        }
    }
    
    func checkTemplates() {
        let templateTypes = ["docx", "xlsx", "pptx"]
        
        // 尝试多个可能的位置
        let possibleLocations = [
            // 1. 应用程序包内
            Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/Templates"),
            // 2. 应用程序包外
            Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("Templates"),
            // 3. 当前工作目录
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Templates")
        ]
        
        // 打印调试信息
        for (index, location) in possibleLocations.enumerated() {
            print("模板位置 \(index+1): \(location.path)")
            print("该位置是否存在: \(FileManager.default.fileExists(atPath: location.path))")
        }
        
        var missingTemplates: [String] = []
        var foundTemplates = false
        
        // 检查每个位置
        for location in possibleLocations {
            if FileManager.default.fileExists(atPath: location.path) {
                foundTemplates = true
                
                // 检查各个模板文件
                var allTemplatesExist = true
                for type in templateTypes {
                    let templatePath = location.appendingPathComponent("Template.\(type)").path
                    if !FileManager.default.fileExists(atPath: templatePath) {
                        missingTemplates.append("Template.\(type)")
                        allTemplatesExist = false
                    }
                }
                
                if allTemplatesExist {
                    // 记录找到的模板目录
                    UserDefaults.standard.set(location.path, forKey: "TemplatesDirectory")
                    print("已找到并保存模板目录: \(location.path)")
                    break
                }
            }
        }
        
        if !foundTemplates {
            missingTemplates = templateTypes.map { "Template.\($0)" }
        }
        
        if !missingTemplates.isEmpty {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "模板文件检查"
                alert.informativeText = "以下模板文件缺失：\n\(missingTemplates.joined(separator: "\n"))\n\n这可能会影响创建Office文件的功能。"
                alert.addButton(withTitle: "确定")
                alert.runModal()
            }
        }
    }
    
    @objc func statusItemClicked() {
        if let button = statusItem.button {
            let position = NSPoint(x: button.frame.midX, y: button.frame.minY)
            showMenu(at: position)
        }
    }
    
    func enableRightClickMonitor() {
        if rightClickMonitor == nil {
            rightClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
                // 获取当前应用
                if let currentApp = NSWorkspace.shared.frontmostApplication,
                   currentApp.bundleIdentifier == "com.apple.finder" {
                    // 仅在Finder中显示菜单
                    self?.showMenu(at: NSEvent.mouseLocation)
                }
            }
        }
    }
    
    func disableRightClickMonitor() {
        if let monitor = rightClickMonitor {
            NSEvent.removeMonitor(monitor)
            rightClickMonitor = nil
        }
    }
    
    @objc func toggleRightClickMonitor(_ sender: NSMenuItem) {
        isRightClickEnabled = !isRightClickEnabled
        
        if isRightClickEnabled {
            enableRightClickMonitor()
            sender.state = .on
            UserDefaults.standard.set(true, forKey: "RightClickEnabled")
        } else {
            disableRightClickMonitor()
            sender.state = .off
            UserDefaults.standard.set(false, forKey: "RightClickEnabled")
        }
    }
    
    func buildMenu() {
        menu = NSMenu()
        
        // 处理主菜单项
        for itemConfig in menuItems {
            // 检查是否为子菜单
            if let submenuItems = itemConfig["submenu"] as? [[String: Any]], 
               let title = itemConfig["title"] as? String {
                
                // 创建包含子菜单的菜单项
                let submenuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                let submenu = NSMenu()
                
                // 处理子菜单项
                for subItem in submenuItems {
                    if let title = subItem["title"] as? String,
                       let action = subItem["action"] as? Selector {
                        
                        // 创建子菜单项
                        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
                        menuItem.target = self
                        submenu.addItem(menuItem)
                    }
                }
                
                // 设置子菜单并添加到主菜单
                submenuItem.submenu = submenu
                menu.addItem(submenuItem)
            } 
            // 处理普通菜单项
            else if let title = itemConfig["title"] as? String,
                     let action = itemConfig["action"] as? Selector {
                
                // 创建普通菜单项
                let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
                menuItem.target = self
                menu.addItem(menuItem)
            }
        }
        
        // 添加分隔线和设置选项
        menu.addItem(NSMenuItem.separator())
        
        // 添加覆盖右键菜单选项
        isRightClickEnabled = UserDefaults.standard.bool(forKey: "RightClickEnabled")
        let rightClickItem = NSMenuItem(title: "覆盖右键菜单（不推荐）", action: #selector(toggleRightClickMonitor(_:)), keyEquivalent: "")
        rightClickItem.target = self
        rightClickItem.state = isRightClickEnabled ? .on : .off
        menu.addItem(rightClickItem)
        
        if isRightClickEnabled {
            enableRightClickMonitor()
        }
        
        // 添加热键提示
        let hotKeyItem = NSMenuItem(title: "快捷键: Option+Command+R", action: nil, keyEquivalent: "")
        hotKeyItem.isEnabled = false
        menu.addItem(hotKeyItem)
        
        // 添加分隔线和退出选项
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func showMenu(at point: NSPoint) {
        menu.popUp(positioning: nil, at: point, in: nil)
    }
    
    // MARK: - 核心功能 -
    @objc func copyFilePath() {
        print("开始执行复制路径操作")
        let file = getSelectedFile()
        
        guard let path = file?.path else {
            print("未能获取选中文件路径")
            showNotification(title: "复制路径失败", body: "未能获取选中文件，请确保在Finder中有选中的文件")
            return
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
        showNotification(title: "已复制路径", body: path)
        print("成功复制路径: \(path)")
    }
    
    @objc func openWithSublime() {
        print("开始执行用Sublime打开文件操作")
        let file = getSelectedFile()
        
        guard let url = file else {
            print("未能获取选中文件URL")
            showNotification(title: "打开失败", body: "未能获取选中文件，请确保在Finder中有选中的文件")
            return
        }
        
        let sublimeAppPath = "/Applications/Sublime Text.app"
        if !FileManager.default.fileExists(atPath: sublimeAppPath) {
            print("未找到Sublime Text应用")
            showNotification(title: "打开失败", body: "未找到Sublime Text应用，请确保已安装")
            return
        }
        
        print("尝试用Sublime Text打开: \(url.path)")
        let configuration = NSWorkspace.OpenConfiguration()
        let sublimeAppURL = URL(fileURLWithPath: sublimeAppPath)
        NSWorkspace.shared.open([url], withApplicationAt: sublimeAppURL, configuration: configuration)
        showNotification(title: "已打开文件", body: "已使用Sublime Text打开\(url.lastPathComponent)")
    }
    
    @objc func openTerminalHere() {
        print("开始执行打开终端操作")
        let file = getSelectedFile()
        
        guard let fileURL = file else {
            print("未能获取选中文件URL")
            showNotification(title: "打开终端失败", body: "未能获取当前文件或目录，请确保在Finder中有选中的项目")
            return
        }
        
        // 获取目录URL
        let dirURL: URL
        var isDir: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDir) {
            if isDir.boolValue {
                dirURL = fileURL
            } else {
                dirURL = fileURL.deletingLastPathComponent()
            }
        } else {
            dirURL = fileURL.deletingLastPathComponent()
        }
        
        print("将在以下目录打开终端: \(dirURL.path)")
        
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(dirURL.path)'"
        end tell
        """
        
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript错误: \(error)")
            showNotification(title: "打开终端失败", body: "执行AppleScript出错: \(error)")
        } else {
            showNotification(title: "已打开终端", body: "位置: \(dirURL.path)")
            print("成功打开终端")
        }
    }
    
    @objc func toggleHiddenFiles() {
        let script = """
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
        end tell
        
        set isHidden to do shell script "defaults read com.apple.finder AppleShowAllFiles"
        
        if isHidden is "1" then
            do shell script "defaults write com.apple.finder AppleShowAllFiles -bool false"
            set newState to "隐藏"
        else
            do shell script "defaults write com.apple.finder AppleShowAllFiles -bool true"
            set newState to "显示"
        end if
        
        do shell script "killall Finder"
        
        return newState
        """
        
        var error: NSDictionary?
        if let result = NSAppleScript(source: script)?.executeAndReturnError(&error).stringValue {
            showNotification(title: "隐藏文件已切换", body: "已将隐藏文件设置为\(result)")
        } else if let error = error {
            print("AppleScript错误: \(error)")
            showNotification(title: "切换隐藏文件失败", body: "执行AppleScript出错")
        }
    }
    
    // 新建文件方法组
    @objc func createTXT() { createNewFile(type: "txt") }
    @objc func createMarkdown() { createNewFile(type: "md") }
    @objc func createWord() { createNewFile(type: "docx") }
    @objc func createExcel() { createNewFile(type: "xlsx") }
    @objc func createPPT() { createNewFile(type: "pptx") }
    
    private func createNewFile(type: String) {
        guard let dirURL = getSelectedFile()?.deletingLastPathComponent() else {
            showNotification(title: "创建文件失败", body: "未能获取当前目录")
            return
        }
        
        // 生成文件名，避免重复
        let baseFileName = "新建文件"
        var fileName = "\(baseFileName).\(type)"
        var fileURL = dirURL.appendingPathComponent(fileName)
        
        // 检查文件是否存在，如果存在则添加序号
        var counter = 1
        while FileManager.default.fileExists(atPath: fileURL.path) {
            fileName = "\(baseFileName) \(counter).\(type)"
            fileURL = dirURL.appendingPathComponent(fileName)
            counter += 1
        }
        
        // 根据文件类型创建
        if ["docx", "xlsx", "pptx"].contains(type) {
            if createOfficeFile(type: type, at: fileURL) {
                showNotification(title: "创建成功", body: "已创建\(fileName)")
                revealFileInFinder(url: fileURL)
            }
        } else {
            // 创建简单文本文件
            let content: Data
            if type == "md" {
                content = "# 新建Markdown文档\n\n".data(using: .utf8) ?? Data()
            } else {
                content = "".data(using: .utf8) ?? Data()
            }
            
            if FileManager.default.createFile(atPath: fileURL.path, contents: content) {
                showNotification(title: "创建成功", body: "已创建\(fileName)")
                revealFileInFinder(url: fileURL)
            } else {
                showNotification(title: "创建失败", body: "无法创建\(fileName)")
            }
        }
    }
    
    private func createOfficeFile(type: String, at path: URL) -> Bool {
        // 首先尝试从Bundle资源中查找
        if let templatePath = Bundle.main.path(forResource: "Template", ofType: type) {
            do {
                try FileManager.default.copyItem(atPath: templatePath, toPath: path.path)
                return true
            } catch {
                print("从Bundle复制模板失败: \(error)")
            }
        }
        
        // 然后尝试从已知的模板目录查找
        var templateLocation: URL?
        
        // 1. 先检查是否已保存模板目录位置
        if let savedPath = UserDefaults.standard.string(forKey: "TemplatesDirectory") {
            templateLocation = URL(fileURLWithPath: savedPath)
        } else {
            // 2. 尝试从多个可能的位置查找
            let possibleLocations = [
                Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/Templates"),
                Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("Templates"),
                URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Templates")
            ]
            
            for location in possibleLocations {
                let testPath = location.appendingPathComponent("Template.\(type)").path
                if FileManager.default.fileExists(atPath: testPath) {
                    templateLocation = location
                    // 保存找到的位置
                    UserDefaults.standard.set(location.path, forKey: "TemplatesDirectory")
                    break
                }
            }
        }
        
        // 从找到的位置复制模板
        if let location = templateLocation {
            let templateURL = location.appendingPathComponent("Template.\(type)")
            
            if FileManager.default.fileExists(atPath: templateURL.path) {
                do {
                    try FileManager.default.copyItem(at: templateURL, to: path)
                    return true
                } catch {
                    print("复制模板失败: \(error)")
                    showNotification(title: "创建失败", body: "无法复制模板文件: \(error.localizedDescription)")
                }
            }
        }
        
        // 如果没有找到模板，创建空文件作为备选方案
        FileManager.default.createFile(atPath: path.path, contents: nil)
        showNotification(title: "创建文件", body: "已创建空的\(type)文件（模板文件不存在或无法访问）")
        return true
    }
    
    // 在Finder中显示文件
    private func revealFileInFinder(url: URL) {
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
    }
    
    // 显示通知
    private func showNotification(title: String, body: String) {
        if #available(macOS 11.0, *) {
            // 使用新的UserNotifications框架
            let center = UNUserNotificationCenter.current()
            
            // 请求授权
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.sound = UNNotificationSound.default
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    center.add(request)
                }
            }
        } else {
            // 使用旧的NSUserNotification (已废弃但在macOS 11.0之前仍可用)
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = body
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    // 获取选中文件路径
    func getSelectedFile() -> URL? {
        // 先尝试激活Finder
        let activateScript = """
        tell application "Finder"
            activate
        end tell
        """
        
        // 执行激活脚本
        var activateError: NSDictionary?
        NSAppleScript(source: activateScript)?.executeAndReturnError(&activateError)
        
        if let error = activateError {
            print("激活Finder失败: \(error)")
        }
        
        // 添加短暂延迟以确保Finder已完全响应
        usleep(50000) // 50毫秒延迟
        
        let script = """
        tell application "Finder"
            set sel to selection as list
            if sel is not {} then
                return POSIX path of (item 1 of sel as alias)
            else
                try
                    return POSIX path of (insertion location as alias)
                on error
                    return POSIX path of (desktop as alias)
                end try
            end if
        end tell
        """
        
        var error: NSDictionary?
        if let result = NSAppleScript(source: script)?.executeAndReturnError(&error) {
            if let path = result.stringValue {
                print("成功获取文件路径: \(path)")
                return URL(fileURLWithPath: path)
            } else {
                print("AppleScript执行成功但未返回路径")
            }
        }
        
        if let error = error {
            print("获取文件路径AppleScript错误: \(error)")
            
            // 尝试备选方案 - 获取Finder前端窗口路径
            let fallbackScript = """
            tell application "Finder"
                try
                    return POSIX path of (target of front window as alias)
                on error
                    return POSIX path of (desktop as alias)
                end try
            end tell
            """
            
            var fallbackError: NSDictionary?
            if let fallbackPath = NSAppleScript(source: fallbackScript)?.executeAndReturnError(&fallbackError).stringValue {
                print("使用备选方案获取路径: \(fallbackPath)")
                return URL(fileURLWithPath: fallbackPath)
            }
            
            if let fallbackError = fallbackError {
                print("备选AppleScript也失败: \(fallbackError)")
            }
        }
        
        print("无法获取选中文件路径，将使用桌面")
        // 最后的备选方案 - 使用桌面
        let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        return desktopPath
    }
}
