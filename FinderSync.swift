//
//  FinderSync.swift
//  RightClickExtension
//
//  Created by kylin on 2025/4/15.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    private let fileOperations = FileOperations.shared
    private let templateManager = TemplateManager.shared
    
    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: "右键工具")
        
        // 基础功能 - 所有功能都始终可用
        menu.addItem(NSMenuItem(title: "复制文件路径", action: #selector(copyFilePath(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "用Sublime打开", action: #selector(openWithSublime(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "在此打开终端", action: #selector(openTerminalHere(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "切换隐藏文件", action: #selector(toggleHiddenFiles(_:)), keyEquivalent: ""))
        
        // 新建文件子菜单
        let newFileItem = NSMenuItem(title: "新建文件", action: nil, keyEquivalent: "")
        let newFileSubMenu = NSMenu()
        
        // 文本文件
        newFileSubMenu.addItem(NSMenuItem(title: "新建TXT", action: #selector(createTXT(_:)), keyEquivalent: ""))
        newFileSubMenu.addItem(NSMenuItem(title: "新建Markdown", action: #selector(createMarkdown(_:)), keyEquivalent: ""))
        newFileSubMenu.addItem(NSMenuItem(title: "新建RTF", action: #selector(createRTF(_:)), keyEquivalent: ""))
        
        // Office文件
        newFileSubMenu.addItem(NSMenuItem(title: "新建Word", action: #selector(createWord(_:)), keyEquivalent: ""))
        newFileSubMenu.addItem(NSMenuItem(title: "新建Excel", action: #selector(createExcel(_:)), keyEquivalent: ""))
        newFileSubMenu.addItem(NSMenuItem(title: "新建PPT", action: #selector(createPPT(_:)), keyEquivalent: ""))
        
        // iWork文件
        newFileSubMenu.addItem(NSMenuItem(title: "新建Pages", action: #selector(createPages(_:)), keyEquivalent: ""))
        newFileSubMenu.addItem(NSMenuItem(title: "新建Numbers", action: #selector(createNumbers(_:)), keyEquivalent: ""))
        newFileSubMenu.addItem(NSMenuItem(title: "新建Keynote", action: #selector(createKeynote(_:)), keyEquivalent: ""))
        
        newFileItem.submenu = newFileSubMenu
        menu.addItem(newFileItem)
        
        return menu
    }
    
    // MARK: - 核心功能实现
    
    @objc func copyFilePath(_ sender: AnyObject) {
        if let items = FIFinderSyncController.default().selectedItemURLs(), let firstItem = items.first {
            // 如果有选中项，复制选中项的路径
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(firstItem.path, forType: .string)
        } else if let currentURL = fileOperations.getCurrentDirectoryURL() {
            // 如果没有选中项，复制当前目录路径
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(currentURL.path, forType: .string)
        }
    }
    
    @objc func openWithSublime(_ sender: AnyObject) {
        let sublimeAppPath = "/Applications/Sublime Text.app"
        guard FileManager.default.fileExists(atPath: sublimeAppPath) else { return }
        
        let configuration = NSWorkspace.OpenConfiguration()
        let sublimeAppURL = URL(fileURLWithPath: sublimeAppPath)
        
        if let items = FIFinderSyncController.default().selectedItemURLs(), let url = items.first {
            // 如果有选中项，打开选中的文件
            NSWorkspace.shared.open([url], withApplicationAt: sublimeAppURL, configuration: configuration)
        } else {
            // 如果没有选中项，直接打开 Sublime
            NSWorkspace.shared.open(sublimeAppURL)
        }
    }
    
    @objc func openTerminalHere(_ sender: AnyObject) {
        guard let dirURL = fileOperations.getCurrentDirectoryURL() else { return }
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(dirURL.path)'"
        end tell
        """
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    @objc func toggleHiddenFiles(_ sender: AnyObject) {
        let script = """
        set isHidden to do shell script "defaults read com.apple.finder AppleShowAllFiles"
        if isHidden is "1" then
            do shell script "defaults write com.apple.finder AppleShowAllFiles -bool false"
        else
            do shell script "defaults write com.apple.finder AppleShowAllFiles -bool true"
        end if
        do shell script "killall Finder"
        """
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    // 新建文件方法组
    @objc func createTXT(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "txt", templateManager: templateManager) }
    @objc func createMarkdown(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "md", templateManager: templateManager) }
    @objc func createWord(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "docx", templateManager: templateManager) }
    @objc func createExcel(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "xlsx", templateManager: templateManager) }
    @objc func createPPT(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "pptx", templateManager: templateManager) }
    @objc func createRTF(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "rtf", templateManager: templateManager) }
    @objc func createPages(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "pages", templateManager: templateManager) }
    @objc func createNumbers(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "numbers", templateManager: templateManager) }
    @objc func createKeynote(_ sender: AnyObject) { _ = fileOperations.createNewFile(type: "key", templateManager: templateManager) }
}

