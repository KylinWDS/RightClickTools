import Foundation

class TemplateManager {
    static let shared = TemplateManager()
    
    // 支持的模板类型
    private let supportedTypes = ["txt", "md", "docx", "xlsx", "pptx", "rtf", "pages", "numbers", "key"]
    
    private init() {}
    
    func getTemplateURL(for type: String) -> URL? {
        // 验证类型是否支持
        guard supportedTypes.contains(type) else {
            return nil
        }
        
        // 获取应用包路径
        guard let appBundlePath = Bundle.main.bundlePath else {
            return nil
        }
        
        // 构建模板文件路径
        let templatesPath = (appBundlePath as NSString)
            .deletingLastPathComponent()  // 移除应用包名
            .deletingLastPathComponent()  // 移除Contents
            .deletingLastPathComponent()  // 移除PlugIns
            .deletingLastPathComponent()  // 移除.app
            .appendingPathComponent("Templates")
            .appendingPathComponent("Template.\(type)")
        
        return URL(fileURLWithPath: templatesPath)
    }
    
    func isTemplateSupported(_ type: String) -> Bool {
        return supportedTypes.contains(type)
    }
} 