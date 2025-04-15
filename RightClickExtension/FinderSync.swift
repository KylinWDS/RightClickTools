//
//  FinderSync.swift
//  RightClickExtension
//
//  Created by kylin on 2025/4/15.
//

import Cocoa
import FinderSync
import UserNotifications

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        
        NSLog("右键扩展初始化，位置: %@", Bundle.main.bundlePath as NSString)
        
        // 设置扩展可用的目录，设置为所有目录
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }
    
    // MARK: - 菜单构建
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        NSLog("构建右键菜单")
        
        // 创建菜单
        let menu = NSMenu(title: "右键工具")
        
        // 添加菜单项
        let copyPathItem = NSMenuItem(title: "复制文件路径", action: #selector(copyFilePath(_:)), keyEquivalent: "")
        copyPathItem.target = self
        menu.addItem(copyPathItem)
        
        let openWithSublimeItem = NSMenuItem(title: "用Sublime打开", action: #selector(openWithSublime(_:)), keyEquivalent: "")
        openWithSublimeItem.target = self
        menu.addItem(openWithSublimeItem)
        
        let openTerminalItem = NSMenuItem(title: "在此打开终端", action: #selector(openTerminalHere(_:)), keyEquivalent: "")
        openTerminalItem.target = self
        menu.addItem(openTerminalItem)
        
        let toggleHiddenFilesItem = NSMenuItem(title: "切换隐藏文件", action: #selector(toggleHiddenFiles(_:)), keyEquivalent: "")
        toggleHiddenFilesItem.target = self
        menu.addItem(toggleHiddenFilesItem)
        
        // 新建文件子菜单
        let newFileItem = NSMenuItem(title: "新建文件", action: nil, keyEquivalent: "")
        let newFileSubMenu = NSMenu()
        
        let newTXTItem = NSMenuItem(title: "新建TXT", action: #selector(createTXT(_:)), keyEquivalent: "")
        newTXTItem.target = self
        newFileSubMenu.addItem(newTXTItem)
        
        let newMarkdownItem = NSMenuItem(title: "新建Markdown", action: #selector(createMarkdown(_:)), keyEquivalent: "")
        newMarkdownItem.target = self
        newFileSubMenu.addItem(newMarkdownItem)
        
        let newWordItem = NSMenuItem(title: "新建Word", action: #selector(createWord(_:)), keyEquivalent: "")
        newWordItem.target = self
        newFileSubMenu.addItem(newWordItem)
        
        let newExcelItem = NSMenuItem(title: "新建Excel", action: #selector(createExcel(_:)), keyEquivalent: "")
        newExcelItem.target = self
        newFileSubMenu.addItem(newExcelItem)
        
        let newPPTItem = NSMenuItem(title: "新建PPT", action: #selector(createPPT(_:)), keyEquivalent: "")
        newPPTItem.target = self
        newFileSubMenu.addItem(newPPTItem)
        
        newFileItem.submenu = newFileSubMenu
        menu.addItem(newFileItem)
        
        return menu
    }
    
    // MARK: - 核心功能实现
    
    @objc func copyFilePath(_ sender: AnyObject) {
        NSLog("执行：复制文件路径")
        guard let items = FIFinderSyncController.default().selectedItemURLs(), let firstItem = items.first else { 
            showNotification(title: "复制路径失败", body: "未能获取选中文件")
            return 
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(firstItem.path, forType: .string)
        showNotification(title: "已复制路径", body: firstItem.path)
    }
    
    @objc func openWithSublime(_ sender: AnyObject) {
        NSLog("执行：用Sublime打开")
        guard let items = FIFinderSyncController.default().selectedItemURLs(), let url = items.first else { 
            showNotification(title: "打开失败", body: "未能获取选中文件")
            return 
        }
        
        let sublimeAppPath = "/Applications/Sublime Text.app"
        if !FileManager.default.fileExists(atPath: sublimeAppPath) {
            showNotification(title: "打开失败", body: "未找到Sublime Text应用")
            return
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        let sublimeAppURL = URL(fileURLWithPath: sublimeAppPath)
        NSWorkspace.shared.open([url], withApplicationAt: sublimeAppURL, configuration: configuration)
        showNotification(title: "已打开文件", body: "已使用Sublime Text打开\(url.lastPathComponent)")
    }
    
    @objc func openTerminalHere(_ sender: AnyObject) {
        NSLog("执行：在此打开终端")
        var dirURL: URL
        
        if let items = FIFinderSyncController.default().selectedItemURLs(), let firstItem = items.first {
            // 检查是否为目录
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: firstItem.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    dirURL = firstItem
                } else {
                    dirURL = firstItem.deletingLastPathComponent()
                }
            } else {
                dirURL = firstItem.deletingLastPathComponent()
            }
        } else if let targetURL = FIFinderSyncController.default().targetedURL() {
            dirURL = targetURL
        } else {
            showNotification(title: "打开终端失败", body: "未能获取当前目录")
            return
        }
        
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(dirURL.path)'"
        end tell
        """
        
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
        
        if let error = error {
            NSLog("AppleScript错误: \(error)")
            showNotification(title: "打开终端失败", body: "执行AppleScript出错")
        } else {
            showNotification(title: "已打开终端", body: "位置: \(dirURL.path)")
        }
    }
    
    @objc func toggleHiddenFiles(_ sender: AnyObject) {
        NSLog("执行：切换隐藏文件")
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
            NSLog("AppleScript错误: \(error)")
            showNotification(title: "切换隐藏文件失败", body: "执行AppleScript出错")
        }
    }
    
    // 新建文件方法组
    @objc func createTXT(_ sender: AnyObject) { createNewFile(type: "txt") }
    @objc func createMarkdown(_ sender: AnyObject) { createNewFile(type: "md") }
    @objc func createWord(_ sender: AnyObject) { createNewFile(type: "docx") }
    @objc func createExcel(_ sender: AnyObject) { createNewFile(type: "xlsx") }
    @objc func createPPT(_ sender: AnyObject) { createNewFile(type: "pptx") }
    
    private func createNewFile(type: String) {
        NSLog("执行：创建新\(type)文件")
        var dirURL: URL
        
        if let targetURL = FIFinderSyncController.default().targetedURL() {
            dirURL = targetURL
        } else if let items = FIFinderSyncController.default().selectedItemURLs(), let firstItem = items.first {
            // 检查是否为目录
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: firstItem.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    dirURL = firstItem
                } else {
                    dirURL = firstItem.deletingLastPathComponent()
                }
            } else {
                dirURL = firstItem.deletingLastPathComponent()
            }
        } else {
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
        // 尝试从模板目录查找
        var templateLocation: URL?
        
        // 1. 查找可能的模板位置
        let mainAppBundle = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let templates = [
            // 应用包内可能的位置
            Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/Templates"),
            // 主应用包内位置
            mainAppBundle.appendingPathComponent("Contents/Resources/Templates"),
            // 项目根目录位置
            mainAppBundle.appendingPathComponent("Templates"),
            // 桌面位置
            FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?.appendingPathComponent("Templates")
        ].compactMap { $0 }
        
        // 打印模板位置
        for (index, location) in templates.enumerated() {
            NSLog("模板位置\(index): \(location.path) - 存在: \(FileManager.default.fileExists(atPath: location.path))")
        }
        
        // 检查各个位置
        for location in templates {
            if FileManager.default.fileExists(atPath: location.path) {
                let testPath = location.appendingPathComponent("Template.\(type)").path
                if FileManager.default.fileExists(atPath: testPath) {
                    NSLog("找到模板: \(testPath)")
                    templateLocation = location
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
                    NSLog("复制模板失败: \(error)")
                    showNotification(title: "创建失败", body: "无法复制模板文件")
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
        NSLog("显示通知: \(title) - \(body)")
        
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
            // 使用旧的NSUserNotification
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = body
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
}

