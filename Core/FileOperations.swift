import Foundation
import Cocoa

class FileOperations {
    static let shared = FileOperations()
    
    private init() {}
    
    func getCurrentDirectoryURL() -> URL? {
        if let items = FIFinderSyncController.default().selectedItemURLs(), !items.isEmpty {
            // 如果有选中项，返回选中项所在目录
            return items.first?.deletingLastPathComponent()
        } else {
            // 如果没有选中项，返回当前目录
            return FIFinderSyncController.default().targetedURL()
        }
    }
    
    func createNewFile(type: String, templateManager: TemplateManager) -> Bool {
        guard let dirURL = getCurrentDirectoryURL() else { return false }
        guard let templateURL = templateManager.getTemplateURL(for: type) else { return false }
        
        let fileName = generateUniqueFileName(type: type, in: dirURL)
        let fileURL = dirURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: templateURL, to: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    private func generateUniqueFileName(type: String, in directory: URL) -> String {
        let baseName = "新建文件"
        var fileName = "\(baseName).\(type)"
        var counter = 1
        
        while FileManager.default.fileExists(atPath: directory.appendingPathComponent(fileName).path) {
            fileName = "\(baseName) \(counter).\(type)"
            counter += 1
        }
        
        return fileName
    }
} 